# Airspace

The general use case for this library is as follows:

I have a materialized/immutable dataset that I wish to temporarily store.  With this temporary storage, I would like to support some level of server-side paging, but I do not need further querying/sorting.

A dataset, in this context, is:
  1. A collection of generic data (i.e. a Ruby hash or some other object)
  2. A two-dimensional array of pages and rows.

What this means is: if you can compute a final form of your dataset and it is immutable then you can use Airspace to temporarily store it in Redis.

## Installation

To install through Rubygems:

````
gem install airspace
````

You can also add this to your Gemfile:

````
bundle add airspace
````

## Examples

### A Basic Example

Say we have the following dataset:

```ruby
dataset = {
  movie_name: 'Avengers',
  rating: 'PG-13',
  release_date: Date.new(2012, 5, 5),
  actors: [
    { id: 1, name: 'Iron Man' },
    { id: 2, name: 'Hulk' },
    { id: 3, name: 'Thor' },
    { id: 4, name: 'Spiderman' },
    { id: 5, name: 'Captain America' }
  ]
}
```

We could split this data up and also paginate the actors:

```ruby
data = dataset.slice(:movie_name, :rating, :release_date)
pages = dataset[:actors].each_slice(2).to_a
```

We can split out the movie 'data' from the actors 'pages' and store it:

```ruby
id = ::Airspace.set(Redis.new, data: data pages: pages)
```

The #set call will return the unique identifier for the stored dataset, which we can now use to retrieve it back:

```ruby
reader = ::Airspace.get(Redis.new, id)
```

The #get call will return an ::Airspace::Reader object that contains the data, metadata (page_count, etc...), and methods to retrieve all or one of the pages.  We could access back the data as:

```ruby
reader.data
```

or get all the pages:

```ruby
reader.pages
```

or just the last page:

```ruby
reader.page(reader.page_count)
```

The value here is that the Reader will only load the initial set of data (movie in our case), while the paged data will only load it all if necessary (or one at a time as needed.)

If you are done with the dataset you can delete it:

```ruby
success = ::Airspace.del(Redis.new, id)
```

### Customization / Options

There are a few options you can leverage:

* Explicitly Specified ID: If you do not specify an id then one will be assigned for you (SecureRandom.uuid)
* Key Prefix: Used for key namespace isolation.  For example: [id: 123, prefix: movies] => key: movies:123
* Custom Serializer: You can pass in your own serializer in case the default methods do not suffice.
* Automatic Expiration (TTL): By default no expiration is set on keys.  This allows you to set one.
* Pages Per Chunk: By default 5 pages will be stored per chunk.  If you think this is not the right balance for your needs you can explicitly pass this in.

The most complex option is the custom serializer.  Airspace comes with a default serializer (::Airspace::Serializer) that defaults to the standard Ruby JSON library.  Here is an example of a custom serializer that will store the data and rows as arrays (instead of hashes):

```ruby
class CustomSerializer < ::Airspace::Serializer
  def serialize_data(obj)
    obj = obj.map { |k, v| [k.to_sym, v] }.to_h

    json_serialize(
      [
        obj[:movie_name],
        obj[:release_date].to_s,
        obj[:rating]
      ]
    )
  end

  def deserialize_data(json)
    array = json_deserialize(json)

    {
      movie_name: array[0],
      release_date: Date.parse(array[1]),
      rating: array[2]
    }
  end

  def serialize_row(obj)
    obj = obj.map { |k, v| [k.to_sym, v] }.to_h

    json_serialize([obj[:id], obj[:name]])
  end

  def deserialize_row(json)
    array = json_deserialize(json)

    {
      id: array[0],
      name: array[1]
    }
  end
end
```

Here is what utilizing all the options would looks like:

```ruby
set_options = {
  expires_in_seconds: 60 * 60 * 12, # 12 hours
  prefix: 'movies',
  serializer: CustomSerializer.new,
  pages_per_chunk: 100
}
id = ::Airspace.set(Redis.new, data: data pages: pages, options: options)

# Cannot use expires_in_seconds or pages_per_chunk
# as they are values stored alongside of the dataset.
get_and_del_options = {
  prefix: 'movies',
  serializer: CustomSerializer.new
}
reader = ::Airspace.get(Redis.new, id, options: get_options)

success = ::Airspace.del(Redis.new, id, options: get_and_del_options)
```

## Contributing

### Development Environment Configuration

Basic steps to take to get this repository compiling:

1. Install [Ruby](https://www.ruby-lang.org/en/documentation/installation/) (check airspace.gemspec for versions supported)
2. Install bundler (gem install bundler)
3. Clone the repository (git clone git@github.com:bluemarblepayroll/airspace.git)
4. Navigate to the root folder (cd airspace)
5. Install dependencies (bundle)

### Running Tests

To execute the test suite run:

````
bundle exec rspec spec --format documentation
````

Alternatively, you can have Guard watch for changes:

````
bundle exec guard
````

Also, do not forget to run Rubocop:

````
bundle exec rubocop
````

### Publishing

Note: ensure you have proper authorization before trying to publish new versions.

After code changes have successfully gone through the Pull Request review process then the following steps should be followed for publishing new versions:

1. Merge Pull Request into master
2. Update the [version number](https://semver.org/) in lib/airspace/version.rb
3. Bundle
4. Update CHANGELOG.md
5. Commit & Push master to remote and ensure CI builds master successfully
6. Build the project locally: `gem build airspace`
7. Publish package to NPM: `gem push airspace-X.gem` where X is the version to push
8. Tag master with new version: `git tag <version>`
9. Push tags remotely: `git push origin --tags`

## License

This project is MIT Licensed.

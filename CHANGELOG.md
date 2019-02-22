# 1.0.1 (February 22, 2019)

**Critical Bug Fix**

* Ensure Reader#page and Reader#pages work when there is a page_count of 0
* Ensure Reader#page works when number is out of bounds (out of bounds is defined as: ```number <= 0``` or ```number > page_count``` )

# 1.0.0 (February 21, 2019)

Initial Release.

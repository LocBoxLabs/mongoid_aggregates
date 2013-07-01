mongoid_aggregates
==================

Extends aggregation support for Mongoid

Installation
-------------

gem install 'mongoid_aggregates'


Examples
--------

Business.aggregates.group('$business_id', count: {'$sum' => '$subscribers.monthly.email_count'}).all

translates to:

[
  {
     "$group": { "_id": "$business_id", "count": { "$sum": "$subscribers.monthly.email_count" } }
  }
]



Business.aggregates.where('subscription.status' => 'active' ).group('subscription.type', count: {'$sum' => 1}).all

translates to:

[
  {
     "$match": { "subscription.status":"active" }
  },
  {
     "$group": { "_id": "$subscription.type", "count": { "$sum": 1 } }
  }
]


License
--------

Copyright (c) 2009-2013 Durran Jordan

Permission is hereby granted, free of charge, to any person obtaining a copy of this software and associated documentation files (the "Software"), to deal in the Software without restriction, including without limitation the rights to use, copy, modify, merge, publish, distribute, sublicense, and/or sell copies of the Software, and to permit persons to whom the Software is furnished to do so, subject to the following conditions:

The above copyright notice and this permission notice shall be included in all copies or substantial portions of the Software.

THE SOFTWARE IS PROVIDED "AS IS", WITHOUT WARRANTY OF ANY KIND, EXPRESS OR IMPLIED, INCLUDING BUT NOT LIMITED TO THE WARRANTIES OF MERCHANTABILITY, FITNESS FOR A PARTICULAR PURPOSE AND NONINFRINGEMENT. IN NO EVENT SHALL THE AUTHORS OR COPYRIGHT HOLDERS BE LIABLE FOR ANY CLAIM, DAMAGES OR OTHER LIABILITY, WHETHER IN AN ACTION OF CONTRACT, TORT OR OTHERWISE, ARISING FROM, OUT OF OR IN CONNECTION WITH THE SOFTWARE OR THE USE OR OTHER DEALINGS IN THE SOFTWARE.

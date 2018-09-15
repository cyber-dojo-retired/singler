
[![Build Status](https://travis-ci.org/cyber-dojo/zipper.svg?branch=master)](https://travis-ci.org/cyber-dojo/zipper)

<img src="https://raw.githubusercontent.com/cyber-dojo/nginx/master/images/home_page_logo.png"
alt="cyber-dojo yin/yang logo" width="50px" height="50px"/>

# cyberdojo/zipper docker image

- A docker-containerized micro-service for [cyber-dojo](http://cyber-dojo.org).
- Creates a tgz file of a practice-session or an individual traffic-light.

API:
  * All methods receive their named arguments in a json hash.
  * All methods return a json hash with a single key.
    * If the method completes, the key equals the method's name.
    * If the method raises an exception, the key equals "exception".

- - - -

# zip
Creates a tgz file of the kata with the given kata_id, in json format
(the format [storer](https://github.com/cyber-dojo/storer) uses).
The caller must share the tgz directory (/tmp_zipper) with zipper.
- parameter, eg
```
  {  "kata_id": "A551C528C3" }
```
- returns the filename of the created tgz file, eg
```
  { "zip": "/tmp_zipper/A551C528C3.tgz" }
```

- - - -

# zip_tag
Creates a tgz file of visible files associated with the kata with
the given kata_id, the avatar with the given avatar_name, and the
traffic-light with the given tag. The tgz file also contains a
manifest.json file suitable for creating a custom
[start-point](http://blog.cyber-dojo.org/2016/08/creating-your-own-start-points.html).
The caller must share the tgz directory (/tmp_zipper) with zipper.
- parameters, eg
```
  {  "kata_id": "A551C528C3",
     "avatar_name": "salmon",
     "tag": 23
  }
```
- returns the filename of the created tgz file, eg
```
  { "zip_tag": "/tmp_zipper/A551C528C3_salmon_23.tgz" }
```

- - - -

* [Take me to cyber-dojo's home github repo](https://github.com/cyber-dojo/cyber-dojo).
* [Take me to http://cyber-dojo.org](http://cyber-dojo.org).

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)


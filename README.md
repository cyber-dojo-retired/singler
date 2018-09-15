
[![Build Status](https://travis-ci.org/cyber-dojo/singler.svg?branch=master)](https://travis-ci.org/cyber-dojo/singler)

<img src="https://raw.githubusercontent.com/cyber-dojo/nginx/master/images/home_page_logo.png"
alt="cyber-dojo yin/yang logo" width="50px" height="50px"/>

# cyberdojo/singler docker image

- A docker-containerized micro-service for [cyber-dojo](http://cyber-dojo.org).
- Stores the visible files, output, and traffic-light status of every test event.
- Work in progress - not yet used

API:
  * All methods receive their named arguments in a json hash.
  * All methods return a json hash with a single key.
    * If the method completes, the key equals the method's name.
    * If the method raises an exception, the key equals "exception".

- [GET sha](#get-sha)
- [GET exists?](#get-exists)
- [GET manifest](#get-manifest)
- [POST create](#post-create)

- - - -

## GET sha
Returns the git commit sha used to create the docker image.
- parameters, none
```
  {}
```
- returns the sha, eg
```
  { "sha": "afe46e4bba4c7c5b630ef7fceda52f29001a10da" }
```

- - - -

## GET exists?
Asks whether the practice-session with the given id exists.
- parameters, eg
```
  { "id": "15B9AD6C42" }
```
- returns true if it does, false if it doesn't, eg
```
  { "exists?": true   }
  { "exists?": false  }
```

- - - -

## POST create
Creates a practice-session from the given json manifest.
- parameter, eg
```
    { "manifest": {
                   "created": [2017,12,15, 11,13,38],
              "display_name": "C (gcc), assert",
                "image_name": "cyberdojofoundation/gcc_assert",
             "visible_files": {        "hiker.h": "#ifndef HIKER_INCLUDED...",
                                       "hiker.c": "#include \"hiker.h\"...",
                                "hiker.tests.c" : "#include <assert.h>\n...",
                                 "instructions" : "Write a program that...",
                                     "makefile" : "CFLAGS += -I. -Wall...",
                                "cyber-dojo.sh" : "make"
                              },
             "runner_choice": "stateless",
                  "exercise": "Fizz_Buzz",
               "max_seconds": 10,
        "filename_extension": [ ".c", "*.h" ],
                  "tab_size": 4,
      }
    }
```
- returns the id of the kata created from the given manifest, eg
```
  { "create": "A551C528C3"
  }
```

- - - -

## GET manifest
Returns the manifest used to create the practice-session with the given id.
- parameter, eg
```
  { "id": "A551C528C3" }
```
- returns, eg
```
    { "manifest": {
                        "id": "A551C528C3",
                   "created": [2017,12,15, 11,13,38],
              "display_name": "C (gcc), assert",
                "image_name": "cyberdojofoundation/gcc_assert",
             "visible_files": {       "hiker.h" : "ifndef HIKER_INCLUDED\n...",
                                      "hiker.c" : "#include \"hiker.h\"...",
                                "hiker.tests.c" : "#include <assert.h>\n...",
                                 "instructions" : "Write a program that...",
                                     "makefile" : "CFLAGS += -I. -Wall...",
                                "cyber-dojo.sh" : "make"
                              },
             "runner_choice": "stateless",
                  "exercise": "Fizz_Buzz",
               "max_seconds": 10,
        "filename_extension": [ ".c", "*.h" ],
                  "tab_size": 4
      }
    }
```

- - - -

* [Take me to cyber-dojo's home github repo](https://github.com/cyber-dojo/cyber-dojo).
* [Take me to http://cyber-dojo.org](http://cyber-dojo.org).

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)


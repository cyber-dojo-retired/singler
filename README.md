
[![Build Status](https://travis-ci.org/cyber-dojo/singler.svg?branch=master)](https://travis-ci.org/cyber-dojo/singler)

<img src="https://raw.githubusercontent.com/cyber-dojo/nginx/master/images/home_page_logo.png"
alt="cyber-dojo yin/yang logo" width="50px" height="50px"/>

# cyberdojo/singler docker image

- A docker-containerized micro-service for [cyber-dojo](http://cyber-dojo.org).
- Creates individual practice sessions.
- Stores the visible files, output, and traffic-light status of every test event.
- Work in progress - not yet used

API:
  * All methods receive their named arguments in a json hash.
  * All methods return a json hash with a single key.
    * If the method completes, the key equals the method's name.
    * If the method raises an exception, the key equals "exception".

- [GET sha](#get-sha)
- [POST create](#post-create)
- [GET manifest](#get-manifest)
- [GET id?](#get-id)
- [GET id_completed](#get-id_completed)
- [GET id_completions](#get-id_completions)
- [POST ran_tests](#post-ran_tests)
- [GET increments](#get-increments)
- [GET visible_files](#get-visible_files)
- [GET tag_visible_files](#get-tag_visible_files)
- [GET tags_visible_files](#get-tags_visible_files)

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

## POST create
Creates a practice-session from the given manifest
and visible_files.
- parameters, eg
```
    { "manifest": {
                   "created": [2017,12,15, 11,13,38],
              "display_name": "C (gcc), assert",
                "image_name": "cyberdojofoundation/gcc_assert",
             "runner_choice": "stateless",
                  "exercise": "Fizz_Buzz",
               "max_seconds": 10,
        "filename_extension": [ ".c", "*.h" ],
                  "tab_size": 4,
      },
      "visible_files": {
               "hiker.h": "#ifndef HIKER_INCLUDED...",
               "hiker.c": "#include \"hiker.h\"...",
        "hiker.tests.c" : "#include <assert.h>\n...",
         "instructions" : "Write a program that...",
             "makefile" : "CFLAGS += -I. -Wall...",
        "cyber-dojo.sh" : "make"
      }
    }
```
- returns the id of the create practice session, eg
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
             "runner_choice": "stateless",
                  "exercise": "Fizz_Buzz",
               "max_seconds": 10,
        "filename_extension": [ ".c", "*.h" ],
                  "tab_size": 4
      }
    }
```

- - - -

## GET id?
Asks whether the practice-session with the given id exists.
- parameters, eg
```
  { "id": "15B9AD6C42" }
```
- returns true if it does, false if it doesn't, eg
```
  { "id?": true   }
  { "id?": false  }
```

- - - -

## GET id_completed
If it exists, returns the 10-digit practice-session id which uniquely
completes the given partial_id, otherwise returns the empty string.
- parameter, the partial-id to complete, eg
```
  { "partial_id": "A551C5" } # must be at least 6 characters long.
```
- returns, eg
```
  { "id_completed": "A551C528C3"  } # completed
  { "id_completed": ""            } # not completed
```

- - - -

## GET id_completions
Returns all the practice-session id's starting with the given outer_id.
- parameter, eg
```
  { "outer_id": "A5" } # must be 2 characters long
```
- returns, eg
```
  { "id_completions": [
       "A551C528C3",
       "A5DA2CDC58",
       "A5EAFE6E53"
    ]
  }
```

- - - -

## POST ran_tests
In the practice-session with the given id,
the given visible files were submitted, at the given time,
which produced the given stdout, stderr, with the given traffic-light colour.
- parameters, eg
```
  {      "id": "A551C528C3",
      "files": {       "hiker.h" : "ifndef HIKER_INCLUDED\n...",
                       "hiker.c" : "#include \"hiker.h\"...",
                 "hiker.tests.c" : "#include <assert.h>\n...",
                  "instructions" : "Write a program that...",
                      "makefile" : "CFLAGS += -I. -Wall...",
                 "cyber-dojo.sh" : "make"
               }
        "now": [2016,12,6, 12,31,15],
     "stdout": "",
     "stderr": "Assert failed: answer() == 42",
     "status": 23,
     "colour": "red"
  }
```
Returns increments, eg
```
  { "ran_tests": [
      {  "event": "created", "time": [2016,12,5, 11,15,18], "number": 0 },
      { "colour": "red,      "time": [2016,12,6, 12,31,15], "number": 1 }
    ]
  }
```

- - - -

## GET increments
Returns details of all traffic-lights, for the practice-session
with the given id.
- parameters, eg
```
  { "id": "A551C528C3" }
```
- returns, eg
```
  { "increments": [
      {  "event": "created", "time": [2016,12,5, 11,15,18], "number": 0 },
      { "colour": "red,      "time": [2016,12,6, 12,31,15], "number": 1 },
      { "colour": "green",   "time": [2016,12,6, 12,32,56], "number": 2 },
      { "colour": "amber",   "time": [2016,12,6, 12,43,19], "number": 3 }
    ]
  }
```

- - - -

## GET visible_files
Returns the most recent set of visible files, for the practice-session
with the given id.
- parameters, eg
```
  { "id": "A551C528C3" }
```
- returns, eg
```
  { "visible_files": {
            "hiker.h" : "ifndef HIKER_INCLUDED\n...",
            "hiker.c" : "#include \"hiker.h\"...",
      "hiker.tests.c" : "#include <assert.h>...",
       "instructions" : "Write a program that...",
           "makefile" : "CFLAGS += -I. -Wall...",
      "cyber-dojo.sh" : "make"
    }
  }
```

- - - -

## GET tag_visible_files
Returns the set of visible files, for the practice-session with the given id,
with the given tag number.
- parameters, eg
```
  {  "id": "A551C528C3",
    "tag": 2
  }
```
- returns, eg
```
  { "tag_visible_files": {
             "hiker.h" : "#ifndef HIKER_INCLUDED\n...",
             "hiker.c" : "#include \"hiker.h\"\n...",
       "hiker.tests.c" : "#include <assert.h>\n...",
        "instructions" : "Write a program that...",
            "makefile" : "CFLAGS += -I. -Wall...",
       "cyber-dojo.sh" : "make"
    }
  }
```

- - - -

## GET tags_visible_files
Returns the paired set of visible files for the practice-session
with the given id, with the given tag numbers.
- parameters, eg
```
  {      "id": "A551C528C3",
    "was_tag": 2,
    "now_tag": 3
  }
```
- returns, eg
```
  { "tags_visible_files": {
      "was_files": {
                  "hiker.h" : "#ifndef HIKER_INCLUDED\n...",
                  "hiker.c" : "#include \"hiker.h\"\n...",
            "hiker.tests.c" : "#include <assert.h>\n...",
            "cyber-dojo.sh" : "make",
         ...
      },
      "now_files": {
               "fizzbuzz.h" : "#ifndef FIZZBUZZ_INCLUDED\n...",
               "fizzbuzz.c" : "#include \"fizzbuzz.h\"\n...",
         "fizzbuzz.tests.c" : "#include <assert.h>\n...",
            "cyber-dojo.sh" : "make",
         ...
      }
    }
  }
```

- - - -

* [Take me to cyber-dojo's home github repo](https://github.com/cyber-dojo/cyber-dojo).
* [Take me to http://cyber-dojo.org](http://cyber-dojo.org).

![cyber-dojo.org home page](https://github.com/cyber-dojo/cyber-dojo/blob/master/shared/home_page_snapshot.png)


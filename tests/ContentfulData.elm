module ContentfulData exposing (..)

getNavigationTree : String
getNavigationTree = """
{
  "sys": {
    "type": "Array"
  },
  "total": 11,
  "skip": 0,
  "limit": 100,
  "items": [
    {
      "sys": {
        "space": {
          "sys": {
            "type": "Link",
            "linkType": "Space",
            "id": "3on7pmzbo8hd"
          }
        },
        "id": "3UjGDZMzRK0guqOSE8gcYY",
        "type": "Entry",
        "createdAt": "2016-08-01T13:45:47.055Z",
        "updatedAt": "2016-08-03T10:22:22.080Z",
        "revision": 3,
        "contentType": {
          "sys": {
            "type": "Link",
            "linkType": "ContentType",
            "id": "document"
          }
        },
        "locale": "en-US"
      },
      "fields": {
        "title": "Getting Started",
        "slug": "getting-started",
        "version": "0.1",
        "content": "These are the guide pages for getting started with the language.",
        "parent": {
          "sys": {
            "type": "Link",
            "linkType": "Entry",
            "id": "6rPDH1vP9YuOQAqqWmaQOi"
          }
        }
      }
    },
    {
      "sys": {
        "space": {
          "sys": {
            "type": "Link",
            "linkType": "Space",
            "id": "3on7pmzbo8hd"
          }
        },
        "id": "4eaVp14bPiaKEU4acKmsE8",
        "type": "Entry",
        "createdAt": "2016-08-02T14:34:10.373Z",
        "updatedAt": "2016-08-03T11:04:31.980Z",
        "revision": 4,
        "contentType": {
          "sys": {
            "type": "Link",
            "linkType": "ContentType",
            "id": "document"
          }
        },
        "locale": "en-US"
      },
      "fields": {
        "title": "String",
        "slug": "string",
        "version": "0.0",
        "content": "A built-in representation for efficient string manipulation. String literals are enclosed in `double quotes`. Strings are _not_ lists of characters.## Basics---### String.isEmpty```elmisEmpty : String -> Bool```Determine if a string is empty.```elmisEmpty  == TrueisEmpty Hello World == False```## Building and Splitting---### String.cons```elmcons : Char -> String -> String```Add a character to the beginning of a string.```elmcons 'H' ello World == Hello World```",
        "parent": {
          "sys": {
            "type": "Link",
            "linkType": "Entry",
            "id": "25y6y2ecp2yse0i8Ww2GUC"
          }
        }
      }
    },
    {
      "sys": {
        "space": {
          "sys": {
            "type": "Link",
            "linkType": "Space",
            "id": "3on7pmzbo8hd"
          }
        },
        "id": "5c2uMZyYDCcCWwKE2YEqYo",
        "type": "Entry",
        "createdAt": "2016-08-03T10:27:32.972Z",
        "updatedAt": "2016-08-03T10:27:43.931Z",
        "revision": 2,
        "contentType": {
          "sys": {
            "type": "Link",
            "linkType": "ContentType",
            "id": "document"
          }
        },
        "locale": "en-US"
      },
      "fields": {
        "title": "Arithmetics",
        "slug": "arithmetics",
        "version": "0.1",
        "content": "Put information here.",
        "parent": {
          "sys": {
            "type": "Link",
            "linkType": "Entry",
            "id": "6dykQ6RfdCc8e2cQYsACky"
          }
        }
      }
    },
    {
      "sys": {
        "space": {
          "sys": {
            "type": "Link",
            "linkType": "Space",
            "id": "3on7pmzbo8hd"
          }
        },
        "id": "79eelQM8IEoyKGuKM804uG",
        "type": "Entry",
        "createdAt": "2016-08-03T10:28:22.401Z",
        "updatedAt": "2016-08-03T10:28:36.056Z",
        "revision": 2,
        "contentType": {
          "sys": {
            "type": "Link",
            "linkType": "ContentType",
            "id": "document"
          }
        },
        "locale": "en-US"
      },
      "fields": {
        "title": "Functions",
        "slug": "functions",
        "version": "0.1",
        "content": "Information about functions in Bit.",
        "parent": {
          "sys": {
            "type": "Link",
            "linkType": "Entry",
            "id": "6dykQ6RfdCc8e2cQYsACky"
          }
        }
      }
    },
    {
      "sys": {
        "space": {
          "sys": {
            "type": "Link",
            "linkType": "Space",
            "id": "3on7pmzbo8hd"
          }
        },
        "id": "25y6y2ecp2yse0i8Ww2GUC",
        "type": "Entry",
        "createdAt": "2016-08-01T08:30:58.713Z",
        "updatedAt": "2016-08-03T10:31:58.799Z",
        "revision": 4,
        "contentType": {
          "sys": {
            "type": "Link",
            "linkType": "ContentType",
            "id": "document"
          }
        },
        "locale": "en-US"
      },
      "fields": {
        "title": "API Reference",
        "slug": "api-reference",
        "version": "0.0",
        "content": "Here is documentation for the modules.## CoreThe core module contains functions that are used by the language. Every application needs a core module, and it needs the specific version of the core module that the binary was compiled for.## AssertInline assertion module for defensive programming.## HTTPModule for HTTP calls.## Log`Log.debug 'Hello World'` is an example of a log message.## String## MathThese are the functions in the math module- Math.abs- Math.ceil- Math.cos- Math.exp- Math.floor- Math.log- Math.log2- Math.max- Math.min- Math.pow- Math.random- Math.round- Math.sin- Math.sqrt- Math.tan- Math.trunc",
        "parent": {
          "sys": {
            "type": "Link",
            "linkType": "Entry",
            "id": "6rPDH1vP9YuOQAqqWmaQOi"
          }
        }
      }
    },
    {
      "sys": {
        "space": {
          "sys": {
            "type": "Link",
            "linkType": "Space",
            "id": "3on7pmzbo8hd"
          }
        },
        "id": "4Yu6MGnJxC4AMwCMIIgs8Y",
        "type": "Entry",
        "createdAt": "2016-08-03T10:32:52.692Z",
        "updatedAt": "2016-08-03T10:33:00.874Z",
        "revision": 2,
        "contentType": {
          "sys": {
            "type": "Link",
            "linkType": "ContentType",
            "id": "document"
          }
        },
        "locale": "en-US"
      },
      "fields": {
        "title": "Modules",
        "slug": "modules",
        "version": "0.1",
        "content": "## Importing modules## Creating modules",
        "parent": {
          "sys": {
            "type": "Link",
            "linkType": "Entry",
            "id": "6dykQ6RfdCc8e2cQYsACky"
          }
        }
      }
    },
    {
      "sys": {
        "space": {
          "sys": {
            "type": "Link",
            "linkType": "Space",
            "id": "3on7pmzbo8hd"
          }
        },
        "id": "6dykQ6RfdCc8e2cQYsACky",
        "type": "Entry",
        "createdAt": "2016-08-01T08:23:54.163Z",
        "updatedAt": "2016-08-03T10:26:31.247Z",
        "revision": 4,
        "contentType": {
          "sys": {
            "type": "Link",
            "linkType": "ContentType",
            "id": "document"
          }
        },
        "locale": "en-US"
      },
      "fields": {
        "title": "Language Reference",
        "slug": "language-ref",
        "version": "0.1",
        "content": "__Bit is a functional language that compiles to WebAssembly.__ It runs on all modern javascript platforms[^1] and is suitable both on the web and in the backend. Bit has a very strong emphasis on simplicity, ease-of-use and quality tooling.[1]: Though some implementations might be considered experimental.",
        "parent": {
          "sys": {
            "type": "Link",
            "linkType": "Entry",
            "id": "6rPDH1vP9YuOQAqqWmaQOi"
          }
        }
      }
    },
    {
      "sys": {
        "space": {
          "sys": {
            "type": "Link",
            "linkType": "Space",
            "id": "3on7pmzbo8hd"
          }
        },
        "id": "6rPDH1vP9YuOQAqqWmaQOi",
        "type": "Entry",
        "createdAt": "2016-08-01T08:22:50.572Z",
        "updatedAt": "2016-08-09T07:05:05.258Z",
        "revision": 9,
        "contentType": {
          "sys": {
            "type": "Link",
            "linkType": "ContentType",
            "id": "document"
          }
        },
        "locale": "en-US"
      },
      "fields": {
        "title": "About this Documentation",
        "slug": "documentation",
        "version": "0.1",
        "content": "The goal of this documentation is to comprehensively explain the Bit language and API, both from a reference as well as a conceptual point of view. Each section describes a built-in module or language concept.Every document is gathered and formatted from a `.json` source. This makes it possible for IDE's and other utilitities to include the documentation in their systems.If you find an error in this documentation, please [submit an issue]() or see [the contributing guide]() for directions on how to submit a patch."
      }
    },
    {
      "sys": {
        "space": {
          "sys": {
            "type": "Link",
            "linkType": "Space",
            "id": "3on7pmzbo8hd"
          }
        },
        "id": "3gpgM76hlC4Y0MAYkEGSO8",
        "type": "Entry",
        "createdAt": "2016-08-03T10:30:18.498Z",
        "updatedAt": "2016-08-03T10:30:18.498Z",
        "revision": 1,
        "contentType": {
          "sys": {
            "type": "Link",
            "linkType": "ContentType",
            "id": "document"
          }
        },
        "locale": "en-US"
      },
      "fields": {
        "title": "Types",
        "slug": "types",
        "version": "0.0",
        "content": "Record types, type alias, unions.",
        "parent": {
          "sys": {
            "type": "Link",
            "linkType": "Entry",
            "id": "6dykQ6RfdCc8e2cQYsACky"
          }
        }
      }
    },
    {
      "sys": {
        "space": {
          "sys": {
            "type": "Link",
            "linkType": "Space",
            "id": "3on7pmzbo8hd"
          }
        },
        "id": "2rYek5JAxqwQKE0OmuuEcs",
        "type": "Entry",
        "createdAt": "2016-08-02T14:33:29.102Z",
        "updatedAt": "2016-08-02T14:33:29.102Z",
        "revision": 1,
        "contentType": {
          "sys": {
            "type": "Link",
            "linkType": "ContentType",
            "id": "document"
          }
        },
        "locale": "en-US"
      },
      "fields": {
        "title": "Core",
        "slug": "core",
        "version": "0.0",
        "content": "This is the core module.",
        "parent": {
          "sys": {
            "type": "Link",
            "linkType": "Entry",
            "id": "25y6y2ecp2yse0i8Ww2GUC"
          }
        }
      }
    },
    {
      "sys": {
        "space": {
          "sys": {
            "type": "Link",
            "linkType": "Space",
            "id": "3on7pmzbo8hd"
          }
        },
        "id": "YYF7vGtJmuIe2CMYOWC48",
        "type": "Entry",
        "createdAt": "2016-08-02T14:35:21.294Z",
        "updatedAt": "2016-08-02T14:35:40.268Z",
        "revision": 2,
        "contentType": {
          "sys": {
            "type": "Link",
            "linkType": "ContentType",
            "id": "document"
          }
        },
        "locale": "en-US"
      },
      "fields": {
        "title": "Math",
        "slug": "math",
        "version": "0.0",
        "content": "These are the functions in the math module-     Math.abs-     Math.ceil-     Math.cos-     Math.exp-     Math.floor-     Math.log-     Math.log2-     Math.max-     Math.min-     Math.pow-     Math.random-     Math.round-     Math.sin-     Math.sqrt-     Math.tan-     Math.truncThese will be fleshen out later.",
        "parent": {
          "sys": {
            "type": "Link",
            "linkType": "Entry",
            "id": "25y6y2ecp2yse0i8Ww2GUC"
          }
        }
      }
    }
  ]
}
"""

getDocumentBySlug : String
getDocumentBySlug = """
{
  "sys": {
    "type": "Array"
  },
  "total": 1,
  "skip": 0,
  "limit": 1,
  "items": [
    {
      "sys": {
        "space": {
          "sys": {
            "type": "Link",
            "linkType": "Space",
            "id": "3on7pmzbo8hd"
          }
        },
        "id": "6rPDH1vP9YuOQAqqWmaQOi",
        "type": "Entry",
        "createdAt": "2016-08-01T08:22:50.572Z",
        "updatedAt": "2016-08-09T07:05:05.258Z",
        "revision": 9,
        "contentType": {
          "sys": {
            "type": "Link",
            "linkType": "ContentType",
            "id": "document"
          }
        },
        "locale": "en-US"
      },
      "fields": {
        "title": "About this Documentation",
        "slug": "documentation",
        "version": "0.1",
        "content": "The goal of this documentation is to comprehensively explain the Bit language and API, both from a reference as well as a conceptual point of view. Each section describes a built-in module or language concept.Every document is gathered and formatted from a `.json` source. This makes it possible for IDE's and other utilitities to include the documentation in their systems.If you find an error in this documentation, please [submit an issue]() or see [the contributing guide]() for directions on how to submit a patch."
      }
    }
  ]
}
"""

search : String
search = """
{
  "sys": {
    "type": "Array"
  },
  "total": 2,
  "skip": 0,
  "limit": 100,
  "items": [
    {
      "sys": {
        "space": {
          "sys": {
            "type": "Link",
            "linkType": "Space",
            "id": "3on7pmzbo8hd"
          }
        },
        "id": "25y6y2ecp2yse0i8Ww2GUC",
        "type": "Entry",
        "createdAt": "2016-08-01T08:30:58.713Z",
        "updatedAt": "2016-08-03T10:31:58.799Z",
        "revision": 4,
        "contentType": {
          "sys": {
            "type": "Link",
            "linkType": "ContentType",
            "id": "document"
          }
        },
        "locale": "en-US"
      },
      "fields": {
        "title": "API Reference",
        "slug": "api-reference",
        "version": "0.0",
        "content": "Here is documentation for the modules.## CoreThe core module contains functions that are used by the language. Every application needs a core module, and it needs the specific version of the core module that the binary was compiled for.## AssertInline assertion module for defensive programming.## HTTPModule for HTTP calls.## Log`Log.debug 'Hello World'` is an example of a log message.## String## MathThese are the functions in the math module- Math.abs- Math.ceil- Math.cos- Math.exp- Math.floor- Math.log- Math.log2- Math.max- Math.min- Math.pow- Math.random- Math.round- Math.sin- Math.sqrt- Math.tan- Math.trunc",
        "parent": {
          "sys": {
            "type": "Link",
            "linkType": "Entry",
            "id": "6rPDH1vP9YuOQAqqWmaQOi"
          }
        }
      }
    },
    {
      "sys": {
        "space": {
          "sys": {
            "type": "Link",
            "linkType": "Space",
            "id": "3on7pmzbo8hd"
          }
        },
        "id": "6rPDH1vP9YuOQAqqWmaQOi",
        "type": "Entry",
        "createdAt": "2016-08-01T08:22:50.572Z",
        "updatedAt": "2016-08-09T07:05:05.258Z",
        "revision": 9,
        "contentType": {
          "sys": {
            "type": "Link",
            "linkType": "ContentType",
            "id": "document"
          }
        },
        "locale": "en-US"
      },
      "fields": {
        "title": "About this Documentation",
        "slug": "documentation",
        "version": "0.1",
        "content": "The goal of this documentation is to comprehensively explain the Bit language and API, both from a reference as well as a conceptual point of view. Each section describes a built-in module or language concept.Every document is gathered and formatted from a `.json` source. This makes it possible for IDE's and other utilitities to include the documentation in their systems.If you find an error in this documentation, please [submit an issue]() or see [the contributing guide]() for directions on how to submit a patch."
      }
    }
  ]
}
"""

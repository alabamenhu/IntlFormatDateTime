use v6.d;
unit grammar DateTimePattern;

# The DateTime pattern grammar is very simple:
# (1) Sequences of a..zA..Z are pattern replacements
# (2) Enclose in single quotes to have literal a..zA..Z
# (3) Double apostrophe escapes a true apostrophe
# (4) All other characters are treated as literal


token TOP                  {     <element>+     }
proto
token element              {         *          }
token element:sym<literal> {      <text>+       }
token element:sym<replace> { (<[a..zA..Z]>) $0* }
proto
token text                 {         *          }
token text:sym<apostrophe> {        \'\'        }
token text:sym<literal>    {   <-[a..zA..Z']>+  }
token text:sym<quoted>     {         \'           # apostrophes only allowed
                            <([<-[']>+||\'\']+)>  # if doubled, action reduces it
                                     \'         } # down to one

# IntlFormatDateTime

> Hoy es siempre todavía, toda la vida es ahora. Y ahora, ahora es el momento de cumplir las promesas que nos hicimos. Porque ayer no lo hicimos, porque mañana es tarde. Ahora.  
> — *Proverbios y cantares* (Antonio Machado)

A module for formatting dates and times in a variety of languages and styles.  To use, simple include the module:

```
use Intl::Format::DateTime
    
my $dt = DateTime.new: now;

format-date $dt;      # Format the date only
format-time $dt;      # Format the time only
format-datetime $dt;  # Format the date and time together
```

The command options are
  * **`:length`**  
The main option, sets the length.  Acceptable values are either *full*, *long*, *medium* (default), *short*.  For the most verbose, choose *wide*.  Defaults to *medium* which should be optimal in most cases.
  * **`:skeleton`** (alias **`:like`**)  
Accepts a string representing various formatting options documented in [TR 35.4.8](https://www.unicode.org/reports/tr35/tr35-dates.html#Date_Field_Symbol_Table).  The optimal pattern is chosen based on the given skeleton, deferring to the skeleton for minor differences (e.g. number of digits).  If used, **length** option is ignored.  
  * **`:language`**  
Sets the language to be used in formatting.  Acceptable values are a `LanguageTag` or a `Str` representation thereof.  Defaults to whatever `User::Language` provides, which itself defaults to `en` (English).
  * **`:relative-to`**  
**NYI**.  This option will create a relative time offset based on the the interval.  Generally `:relative-to(now)` is what you will want to use, but you can use anything that can coerce to a DateTime.  

If you will be constantly reusing a formatter, you can also obtain a `Callable` form which will reduce some of the overhead and be more performant:

```raku
my &formatter =    local-datetime-formatter :$language, :$length, :$skeleton;
              # or local-date-formatter
              # or local-time-formatter
              
formatter DateTime.now
```

Current performance is about an order of magnitude slower than `DateTime.Str` and is about as fast as vanilla Raku can get. 
The performance gap can be narrowed if alternate `nqp` versions of formatters are written, but that is not a priority at the moment.
## To do

  * Finish skeleton patterns support (allowing selection of more specific formats).
  * Respect capitalization rules per CLDR casing data.
  * Handle non-Gregorian calendars (once a `DateTime::Calendars` module or similar is available)
  * Handle relative time formats (though this may ultimately go into a separate module).

## Dependencies

  * `Intl::LanguageTag`  
  Used for introspection of language tags.
  * `Intl::UserLanguage`  
  Determines the default language for formatting).
  * `Intl::CLDR`  
  Contains formatting information.
  * `DateTime::Timezones`  
  Ensures that `DateTime` objects are timezone aware.

These modules are designed to work together, and as of 2023, are maintained by the same person so should not have issues if fully updated.

## Version history

  * **v0.3.0**
    * All code now runs with RakuAST for improved performance
    * Added `local-datetime-formatter` calls for enhanced performance in some situations
    * Proper week-of-year/weekyear support
    * Non-Latin digit support 
    * Restructured file hierarchy for better long term maintenance
  * **v0.2.0**
    * Skeleton formats supported for `format-datetime` (NYI: missing fields and C/j/J formatters NYI)
  * **v0.1**
    * Initial release

## Copyright and License

© 2021–2023 Matthew Stephen Stuckwisch. All files licensed under the Artistic License 2.0 except for `resources/metaZones.xml` which is owned by Unicode, Inc. and licensed under the Unicode License Agreement (found at `resources/unicode-license.txt`)
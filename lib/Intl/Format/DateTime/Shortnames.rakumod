use v6.d;
unit module Shortnames;
# RakuAST::Statement::Use.new(
#    module-name => RakuAST::Name.from-identifier-parts('Intl','CLDR','DateTime','Metazones')
# );

constant %bcp47-shortname := BEGIN Map.new: %?RESOURCES<timezone-bcp47.data>.lines;

sub bcp47-shortname($olson-id) is export {
    %bcp47-shortname{$olson-id} // Nil
}

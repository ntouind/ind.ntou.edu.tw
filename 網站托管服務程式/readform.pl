sub ReadForm
{
  local (*in) = @_ if @_;
  local ($i, $key, $val);

  # Read in text
  if ($ENV{'REQUEST_METHOD'} eq "GET") {
    $in = $ENV{'QUERY_STRING'};
  } elsif ($ENV{'REQUEST_METHOD'} eq "POST") {
      read(STDIN,$in,$ENV{'CONTENT_LENGTH'});
      if ($ENV{'QUERY_STRING'} =~ /=/) {
        $in = join("&", $in, $ENV{'QUERY_STRING'});
      }
  }

  @in = split(/&/,$in);

  foreach $i (0 ..$#in) {
    # Convert plus's to spaces
    $in[$i] =~ tr/+/ /;

    # Split into key and value
    # splits on the first =
    ($key, $val) = split(/=/,$in[$i],2);

    # Convert %XX from hex numbers to alphanumeric
    $key =~ s/%(..)/pack("C",hex($1))/ge;
    $val =~ s/%(..)/pack("C",hex($1))/ge;

    # Kill SSI command
    $val =~ s/<!--(.|\n)*-->//g;

    # Associate key and value
    # \0 is the multiple separator
    if (defined($in{$key})) {
      $in{$key} = join("\0", $in{$key}, $val);
    } else {
      $in{$key} = $val;
    }
  }

  return ($in);
}

1;
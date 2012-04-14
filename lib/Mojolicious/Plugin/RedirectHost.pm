package Mojolicious::Plugin::RedirectHost;
use Mojo::Base 'Mojolicious::Plugin';

# where to look for options
my $CONFIG_KEY   = 'redirect_host';
my $DEFAULT_CODE = 301;

sub register {
  my ($self, $app, $params) = @_;

  my %options;
  if (ref $params eq 'HASH' && scalar keys %$params) {
    %options = %$params;
  }
  elsif (ref $app->config($CONFIG_KEY) eq 'HASH') {
    %options = %{$app->config($CONFIG_KEY)};
  }

  unless ($options{host}) {
    $app->log->error('RedirectHost plugin: define "host" option at least!');
    return;
  }

  $app->hook(
    before_dispatch => sub {
      my $c   = shift;
      my $url = $c->req->url->to_abs;

      # don't need redirection
      return if $url->host eq $options{host};

      # main host
      $url->host(delete local $options{host});
      
      # code      
      $c->res->code(delete local $options{code} || $DEFAULT_CODE);
      
      foreach my $what (keys %options) {
        $url->$what($options{$what})     if $options{$what};
      }
=pod      
      $url->scheme($options{scheme}) if $options{scheme};
      $url->port($options{port})     if $options{port};
      $url->path($options{path})     if $options{path};
      $url->query($options{query})   if $options{query};
=cut
      $c->redirect_to($url->to_string);
    }
  );

  return;
}


=head1 NAME

Mojolicious::Plugin::RedirectHost - Redirects requests from mirrors to the main host (usefull for SEO)

=head1 VERSION

Version 0.01_01

=cut

our $VERSION = '0.01_01';


=head1 SYNOPSIS

!!! AHTUNG. This is the development release, documentation will be available soon (or may be not).
I have uploaded this module to CPAN only for test purposes.


  # 301: http://mirror.main.host/path?query -> http://main.host/path?query
  $app->plugin('RedirectHost', host => 'main.host');

Теперь любые запросы, приходящие на зеркало (тобишь если заголовок запроса "Host" не совпадает с параметром "host"), будут переадресовываться на основной хост, по умолчанию со статусом 301.
Это для того, чтобы Яндекс, Шмандекс и Гугл не разбавляли показатели сайта.

Поведение переадресатора можно изменить: все параметры, кроме code, становятся методами объекта Mojo::URL

  # 302: http://mirror.main.host/foo -> https://main.host:8000/bar?a=b
  $app->plugin(
    'RedirectHost',
    host   => 'main.host',
    code   => 302,
    scheme => 'https',
    port   => 8000,
    path   => '/bar',
    query  => {a => 'b'}
  );

Необходимые настройки можно указать в конфиге по ключу "redirect_host".

  $app->config(redirect_host => {host => 'main.host'});

=head1 SUBROUTINES/METHODS

=head1 TODO

Play around requests without "Host" header like this:
  
  GET / HTTP/1.1


=head1 AUTHOR

Alex, C<< <alexbyk at cpan.org> >>

=head1 BUGS

Please report any bugs or feature requests to C<bug-mojolicious-plugin-redirecthost at rt.cpan.org>, or through
the web interface at L<http://rt.cpan.org/NoAuth/ReportBug.html?Queue=Mojolicious-Plugin-RedirectHost>.  I will be notified, and then you'll
automatically be notified of progress on your bug as I make changes.




=head1 SUPPORT

You can find documentation for this module with the perldoc command.

    perldoc Mojolicious::Plugin::RedirectHost


You can also look for information at:

=over 4

=item * RT: CPAN's request tracker (report bugs here)

L<http://rt.cpan.org/NoAuth/Bugs.html?Dist=Mojolicious-Plugin-RedirectHost>

=item * AnnoCPAN: Annotated CPAN documentation

L<http://annocpan.org/dist/Mojolicious-Plugin-RedirectHost>

=item * CPAN Ratings

L<http://cpanratings.perl.org/d/Mojolicious-Plugin-RedirectHost>

=item * Search CPAN

L<http://search.cpan.org/dist/Mojolicious-Plugin-RedirectHost/>

=back


=head1 ACKNOWLEDGEMENTS


=head1 LICENSE AND COPYRIGHT

Copyright 2012 Alex.

This program is free software; you can redistribute it and/or modify it
under the terms of either: the GNU General Public License as published
by the Free Software Foundation; or the Artistic License.

See http://dev.perl.org/licenses/ for more information.


=cut

1;    # End of Mojolicious::Plugin::RedirectHost

package Mojolicious::Plugin::RedirectHost;
use Mojo::Base 'Mojolicious::Plugin';
use Mojo::URL;

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
      $url->host($options{host});
        #$url->host(delete local $options{host});

      # code      
      $c->res->code($options{code} || $DEFAULT_CODE);
        #$c->res->code(delete local $options{code} || $DEFAULT_CODE);

      if (ref $options{url} eq 'HASH') {

        # замещаем значения
        foreach my $what (keys %{$options{url}}) {
          $url->$what($options{url}->{$what}) if $options{url}->{$what};
        }
      }
      elsif(ref $options{url}) {
        # replace a whole url with a passed Mojo::URL object
        $url = $options{url};
      }
      elsif ($options{url}) {
        # replace a whole url with a new one
        $url = Mojo::URL->new($options{url});
      }


      $c->redirect_to($url->to_string);
    }
  );

  return;
}


=head1 NAME

Mojolicious::Plugin::RedirectHost - Redirects requests from mirrors to the main host (usefull for SEO)

=head1 VERSION

Version 0.01_02

=cut

our $VERSION = '0.01_02';


=head1 SYNOPSIS

!!! AHTUNG. This is the development release, documentation will be available soon (or may be not).
I have uploaded this module to CPAN only for test purposes.


  # 301: http://mirror.main.host/path?query -> http://main.host/path?query
  $app->plugin('RedirectHost', host => 'main.host');

Теперь любые запросы, приходящие на зеркало (тобишь если заголовок запроса "Host" не совпадает с параметром "host"), будут переадресовываться на основной хост, по умолчанию со статусом 301.
Это для того, чтобы Яндекс, Шмандекс и Гугл не разбавляли показатели сайта.

Поведение переадресатора можно изменить: все параметры в хеше 'url' становятся методами объекта Mojo::URL, те, которые не затираются - берутся с текущего запроса
  
  # 302: http://mirror.main.host/path?query -> http://main.host/path?query
  $app->plugin('RedirectHost', host => 'main.host', code => 302);
  
Можно изменить только некоторые из текущего запроса {}

  # http://mirror.main.host/foo -> https://main.host/foo?a=b
  $app->plugin(
    'RedirectHost',
    host   => 'main.host',    
    url => { scheme => 'https', query  => {a => 'b'} }
  );
  
Полность указать новый запрос (строкой)

  # http://mirror.main.host/foo -> http://google.com
  $app->plugin(
    'RedirectHost',
    host   => 'main.host',    
    url => 'http://google.com'
  );
  
  
Указать новый запрос объектом Mojo::URL

  # http://mirror.main.host/foo -> http://google.com
  $app->plugin(
    'RedirectHost',
    host => 'main.host',    
    url  => Mojo::URL->new('http://google.com')
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

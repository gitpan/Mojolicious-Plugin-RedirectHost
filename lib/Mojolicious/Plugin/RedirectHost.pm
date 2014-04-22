package Mojolicious::Plugin::RedirectHost;

use Mojo::Base 'Mojolicious::Plugin';
use Mojo::URL;

our $VERSION = '1.00';    # VERSION

# where to look for options
my $CONFIG_KEY   = 'redirect_host';
my $DEFAULT_CODE = 301;
my $EXCEPT_PATH  = '/robots.txt';

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
    my $msg = 'RedirectHost plugin: define "host" option at least!';
    $app->log->error($msg) unless $options{silent};

    return;
  }

  $app->hook(
    before_dispatch => sub {
      my $c    = shift;
      my $url  = $c->req->url->to_abs;
      my $path = $c->req->url->path;


      # don't need redirection
      return if $url->host eq $options{host};

      # except_robots?
      if ($options{er}) {
        return if $path eq $EXCEPT_PATH;
      }

      # main host
      $url->host($options{host});

      # code
      $c->res->code($options{code} || $DEFAULT_CODE);


      $c->redirect_to($url->to_string);
    }
  );

  return;
}

1;

# ABSTRACT: Redirects requests from mirrors to the main host (useful for SEO)

__END__

=pod

=encoding UTF-8

=head1 NAME

Mojolicious::Plugin::RedirectHost - Redirects requests from mirrors to the main host (useful for SEO)

=head1 VERSION

version 1.00

=head1 SYNOPSIS

Generates 301 redirect from C<http://mirror.main.host/path?query> to C<http://main.host/path?query>

  # Mojolicious
  $app->plugin('RedirectHost', host => 'main.host');
  
  # Mojolicious::Lite
  plugin RedirectHost => { host => 'main.host' };

All requests with C<Host> header that are not equal to the C<host> option will be redirected to the main host
It would be better if you'll be using per mode config files (your_app.production.conf etc). This would make possible
to redirect only in production enviropment (but do nothing while coding your app)

=head1 OPTIONS/USAGE

=head2 C<host>

Main domain. All requests to the mirrors will be redirected to the C<host> (domain)
This option is required. Without it plugin do nothing

=head2 C<code>

  $app->plugin('RedirectHost', host => 'main.host', code => 302);

Type of redirection. Default 301 (Moved Permanently)

=head2 C<er> (except /rotots.txt)

  $app->plugin('RedirectHost', host => 'main.host', er => 1);

If true, requests like /robots.txt will not be redirected but rendered. That's for Yandex search engine.
If you want to change a domain but worry about yandex TIC, it's recomended to make it possible for Yandex to read your robots.txt
with new Host directive. If so, that's exactly what you're looking for

=head2 C<silent>

If C<silent> is true, doesn't write messages to the error log even if L</host> is missing.
Default value is C<false>

You can configure plugin in a production config file and define C<silent> in a development config.

	# app.production.conf
	# redirect_host => {host => 'main.host'},

	# app.development.conf: 
	# redirect_host => {silent => 1},

=head1 CONFIG

You can pass options to the plugin with the help of your config. Use C<redirect_host> key.

  $app->config(redirect_host => {host => 'main.host'});

TIP: use per mode config files (yourapp.production.conf) to pass parameters to the plugin to avoid redirection during
development process

=head1 METHODS

=head2 register

Register.  L<Mojolicious::Plugin/register>

=head1 AUTHOR

alexbyk <alex@alexbyk.com>

=head1 COPYRIGHT AND LICENSE

This software is copyright (c) 2014 by alexbyk.

This is free software; you can redistribute it and/or modify it under
the same terms as the Perl 5 programming language system itself.

=cut

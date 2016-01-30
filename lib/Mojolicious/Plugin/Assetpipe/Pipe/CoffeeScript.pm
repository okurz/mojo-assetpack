package Mojolicious::Plugin::Assetpipe::Pipe::CoffeeScript;
use Mojo::Base 'Mojolicious::Plugin::Assetpipe::Pipe';
use Mojolicious::Plugin::Assetpipe::Util qw(diag DEBUG);

sub _install_coffee {
  my $self = shift;
  my $path = $self->app->home->rel_file(qw(node_modules .bin coffee));
  return $path if -e $path;
  $self->app->log->warn('Installing coffee... Please wait. (npm install coffee)');
  $self->run([qw(npm install coffee)]);
  return $path;
}

sub _process {
  my ($self, $assets) = @_;
  my $store = $self->assetpipe->store;
  my $file;

  $assets->each(
    sub {
      my ($asset, $index) = @_;
      return if $asset->format ne 'coffee';
      my $attrs = $asset->TO_JSON;
      @$attrs{qw(format key)} = qw(js coffee);
      return $asset->content($file)->FROM_JSON($attrs) if $file = $store->load($attrs);
      diag 'Process "%s" with checksum %s.', $asset->url, $attrs->{checksum} if DEBUG;
      $self->run([qw(coffee --compile --stdio)], \$asset->content, \my $js);
      $asset->content($store->save(\$js, $attrs))->FROM_JSON($attrs);
    }
  );
}

1;

=encoding utf8

=head1 NAME

Mojolicious::Plugin::Assetpipe::Pipe::CoffeeScript - Process CoffeeScript

=head1 DESCRIPTION

L<Mojolicious::Plugin::Assetpipe::Pipe::CoffeeScript> will process
L<http://coffeescript.org/> files into JavaScript.

This module require the C<coffee> program to be installed. C<coffee> will be
automatically installed using L<https://www.npmjs.com/> unless already
installed.

=head1 SEE ALSO

L<Mojolicious::Plugin::Assetpipe>.

=cut
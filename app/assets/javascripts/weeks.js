// This is to get the weeks dropdown to not hide under the header when opened.
$('.dropdown').on('show.bs.dropdown', function() {
  $('body').append($('.dropdown').css({
    position: 'absolute',
    left: $('.dropdown').offset().left,
    top: $('.dropdown').offset().top
  }).detach());
});

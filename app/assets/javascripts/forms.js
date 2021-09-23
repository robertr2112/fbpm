/* Setup the select2 functions */
/* $(document).ready(function() { */
$( document ).on('turbolinks:load', function() {

  setSelect2Format();

  $('.links').on('cocoon:after-insert', function() {
    /* alert ("In cocoon:after-insert..."); */
    setSelect2Format();

  });
});

function setSelect2Format() {

  /* alert ("setSelect2Format called..."); */
  $('.hometeam').select2({
    theme: "bootstrap",
    placeholder: "Home Team",
    allowClear: true,
    width: '230px'
  });

  $('.awayteam').select2({
    theme: "bootstrap",
    placeholder: "Away Team",
    allowClear: true,
    width: '230px'
  });

  $('#gamePick').select2({
    theme: "bootstrap",
    width: '230px'
  });

  $(".emailPoolList").select2({
    theme: "bootstrap",
    allowClear: true
  });

  $(".gamePickSelect").select2({
    placeholder: "Pick team",
    allowClear: true
  });

};

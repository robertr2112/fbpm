// Use select2 for picking teams
// $(document).ready(function() { $("#gamePick").select2(); });
(function($){
    $(document).on('turbolinks:load', function() {
       $("#gamePick").select2({
           theme: "bootstrap"
       });
    });
}(jQuery));

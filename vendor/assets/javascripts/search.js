function changeSort( which ) {
    if($('#sort').val() == which+" DESC") {
        $('#sort').val(which+" ASC");
    } else {
        $('#sort').val(which+" DESC");
    }
    $('#search_form').submit();
}
/*
 * jGD DropDown
 * Version 0.3 (23-JUL-2010)
 * @requires jQuery v1.2.3 or later
 *
 * Homepage: http://www.dev4press.com/jquery/jgd-dropdown/
 * Examples: http://www.dev4press.com/jgd/dropdown/
 * 
 * Copyright (c) 2008-2010 Milan Petrovic, Dev4Press
 *
 * Dual licensed under the MIT and GPL licenses:
 * http://www.opensource.org/licenses/mit-license.php
 * http://www.gnu.org/licenses/gpl.html
 *
 * Thanks to Janko at Warp Speed for this great article:
 * http://www.jankoatwarpspeed.com/post/2009/07/28/reinventing-drop-down-with-css-jquery.aspx
 */

(function($){
    $.fn.jgdDropdown = function(options) {
        var settings =  $.extend({}, $.fn.jgdDropdown.defaults, options);
        return this.each(function() {
            var $this = $(this);
            var $id = $.fn.jgdDropdown.convert($this, settings);

            $("#" + $id + " dt a").click(function() {
                $("dd ul").hide();
                $("#" + $id + " dd ul").show();
                return false;
            });

            $(document).bind('click', function(e) {
                var $clicked = $(e.target);
                if (!$clicked.parents().hasClass(settings.cls))
                    $("." + settings.cls + " dd ul").hide();
            });

            $("#" + $id + " dd ul li a").click(function() {
                var $sel = $(this);
                var $val = $sel.find("span.value").html();
                $("#" + $id + " dt a").html($sel.html());
                $("#" + $id + " dd ul").hide();
                $this.val($val);
                if (settings.callback) {
                    settings.callback($this, $val);
                }
                return false;
            });
        });
    };
    $.fn.jgdDropdown.defaults = {
        callback: null,
        cls: 'jgd-dropdown',
        clsLIPrefix: '',
        clsLIExpand: true,
        selected: ''
    };
    $.fn.jgdDropdown.convert = function($obj, settings) {
        if (settings.selected != null != null && settings.selected != '') {
            $obj.val(settings.selected);
        }
        var selected = $obj.find("option[selected]");
        var options = $("option", $obj);
        var id = "jgd_dd_" + get_id($obj);
        $obj.after('<dl id="' + id + '" class="' + settings.cls + '"></dl>');
        $("#" + id).append('<dt><a href="#">' + selected.text() + '<span class="value">' + selected.val() +  '</span></a></dt>');
        $("#" + id).append('<dd><ul></ul></dd>');
        options.each(function(index){
            var cls = settings.clsLIPrefix + $(this).val();
            if (settings.clsLIExpand) {
                cls += " item-" + index;
                cls += " item-" + ($.fn.jgd.isEven(index) ? "even" : "odd");
                if (index == 0) cls += " item-first";
                if (index == options.length - 1) cls += " item-last";
            }
            $("#" + id + " dd ul").append('<li class="' + cls + '"><a href="#">' +
                $(this).text() + '<span class="value">' +
                $(this).val() + '</span></a></li>');
        });
        $obj.hide();
        return id;
    };
    $.fn.jgd = function() {};
    $.fn.jgd.isEven = function($num) {
        return ($num%2 == 0);
    };
    function get_id($obj) {
        var id = $obj.attr("id");
        if (id == "") {
            id = random_id();
        }
        return id;
    };
    function random_id() {
        var dt = new Date().getMilliseconds();
        var num = Math.random();
        var rnd = Math.round(num * 100000);
        return "jgd" + dt + rnd;
    };
    function debug($obj) {
        if (window.console && window.console.log) {
             window.console.log('jgd_dropdown: ' + $obj.size());
        }
    };
})(jQuery);

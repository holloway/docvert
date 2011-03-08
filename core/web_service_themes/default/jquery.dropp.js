/*
 * Dropp
 * http://github.com/matrushka/Dropp
 * @requires jQuery v1.3 or later
 * 
 * Dropp is a jQuery plugin which replaces regular droprown menus ( <select> elements ) with stylable alternatives.
 *
 * 2010 - Baris Gumustas
 */
(function ($) {
	$.fn.dropp = function (user_settings) {
		var settings = {
			'phrase_on_multiple'          : false,
			'class_dropdown_wrapper'      : 'dropdown_wrapper',
			'class_dropdown_list'         : 'dropdown_list',
			'class_visible_dropdown'      : 'dropdown',
			'class_option_selected'       : 'selected',
			'substract_list_border_width' : true
		};
		if (user_settings) {
			$.extend(settings, user_settings);
		}
		return this.each(function () {
			var select, dropdown, list, values, list_width, widest_element;
			widest_element = null;
			
			select = $(this);
			select.hide();
			select.wrap('<div></div>').parent().attr('class', select.attr('class')).addClass(settings.class_dropdown_wrapper);
			
			dropdown = $('<a href="#"/>').addClass(settings.class_visible_dropdown).appendTo(select.parent());
			list = $('<ul/>').addClass(settings.class_dropdown_list).addClass('dropp_dropdown_list').hide().appendTo(select.parent());
			
			// duplicate this line for dropdown opening
			list_width = dropdown.get(0).offsetWidth;
			
			if (settings.substract_list_border_width) {
				list_width -= (parseInt(list.css('borderLeftWidth'), 10) + parseInt(list.css('borderRightWidth'), 10));
			}
			
			list.css('min-width', list_width);
			
			list.css('position', 'absolute').css('z-index', '9999');
			
			select.find('option').each(function () {
				var item, list, list_item, link;
				item = $(this);
				list = item.closest('.' + settings.class_dropdown_wrapper).find('ul.dropp_dropdown_list');
				list_item = $('<li/>').appendTo(list);
				link = $('<a href="#"/>').text(item.text());
				
				link.data('option', item);
				list_item.append(link);
				item.data('replacement', link);
				
				if (typeof select.attr('multiple') !== undefined && (select.attr('multiple') === true || select.attr('multiple') === 'multiple')) {
					if (typeof item.attr('selected') !== undefined && (item.attr('selected') === true || item.attr('selected') === 'selected')) {
						link.addClass(settings.class_option_selected);
					}
				}
				
				// Select Event Listener
				link.bind('select', function (event, trigger_drowndown) {
					var link, wrapper, item, select, dropdown, values;
					link = $(this);
					wrapper = link.closest('.' + settings.class_dropdown_wrapper);
					item = link.data('option');
					select = wrapper.find('select');
					dropdown = wrapper.find('.' + settings.class_visible_dropdown);
					
					if (typeof select.attr('multiple') === 'undefined' || select.attr('multiple') === false) {
						select.find('option:selected').removeAttr('selected');
                        var selected_text = $('<div/>').text($(this).text()).html();
    					dropdown.html(selected_text + '<span class="ddl_icon">&#9660;</span>');
						//dropdown.text($(this).text() + "-");
						item.attr('selected', 'selected');
						list.hide();
					} else {
						if (typeof item.attr('selected') === 'undefined' || item.attr('selected') === false) {
							item.attr('selected', 'selected');
							link.addClass(settings.class_option_selected);
						} else {
							item.removeAttr('selected');
							link.removeClass(settings.class_option_selected);
						}
						
						values = [];
						select.find('option:selected').each(function () {
							values.push($(this).text());
						});
						
						if (values.length === 0) {
							if (typeof select.attr('placeholder') !== 'undefined') {
								dropdown.text(select.attr('placeholder'));
							} else {
								dropdown.html('&nbsp;');
							}
						} else {
							if (values.length > 1 && settings.phrase_on_multiple) {
								dropdown.text(settings.phrase_on_multiple);
							} else {
								dropdown.text(values.join(', '));
							}
						}
					}

					if (trigger_drowndown) {
						select.trigger('change');
					}
				});
				// Click Event
				link.click(function () {
					$(this).trigger('select', [true]);
					return false;
				});
			});
			

			// Check for IE and apply a hack here for min-width problems
			if ($.browser.msie && $.browser.version === '6.0') {
				// Look for the widest option
				list.find('a').each(function(){
					if (widest_element === null || widest_element.width() < $(this).width()) {
						widest_element = $(this);
					}
				});
				if (widest_element.width() > list_width) {
					list.width(widest_element.width());
				} else {
					list.width(list_width);
				}
				
			}
			
			// Each loop ends here
			if (select.find('option:selected').length === 0) {
				if (typeof select.attr('placeholder') !== 'undefined') {
					dropdown.text(select.attr('placeholder'));
				} else {
					dropdown.html('&nbsp;');
				}
			} else {
				if (typeof select.attr('multiple') !== undefined && (select.attr('multiple') === true || select.attr('multiple') === 'multiple')) {
					values = [];
					select.find('option:selected').each(function () {
						values.push($(this).text());
					});
					dropdown.html(values.join(', '));
				} else {
                    var selected_text = $('<div/>').text($(this).find('option:selected').text()).html();
					dropdown.html(selected_text + '<span class="ddl_icon">&#9660;</span>');
				}
			}
			
			dropdown.click(function () {
				if (list.is(':visible')) {
					list.hide();
					$('ul.dropp_dropdown_list').hide();
				} else {
					$('ul.dropp_dropdown_list').hide();
					list.show();
				}
				return false;
			});
			
			$(document).click(function () {
				list.hide();
			});
			
			$('.' + settings.class_dropdown_wrapper).click(function (event) {
				event.stopPropagation();
			});
		});
	};
}(jQuery));

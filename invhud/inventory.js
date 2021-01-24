var type = "normal";
var disabled = false;
var disabledFunction = null;
var curIcon = "$";

window.addEventListener("message", function (event) {
    if (event.data.action == "display") {
      type = event.data.type
      disabled = false;
      $(".info-div").show();
      $(".ui").fadeIn();
    } else if (event.data.action == "hide") {
        $("#dialog").dialog("close");
        $(".ui").fadeOut();
        $(".item").remove();
        $("#otherInventory").html("<div id=\"noSecondInventoryMessage\"></div>");
        $("#noSecondInventoryMessage").html(invLocale.secondInventoryNotAvailable);
    } else if (event.data.action == "setItems") {
      inventorySetup(event.data.itemList);
      createItems();
    } else if (event.data.action == "setSecondInventoryItems") {
      secondInventorySetup(event.data.itemList);
      createItems();
    } else if (event.data.action == "setShopInventoryItems") {
      shopInventorySetup(event.data.itemList)
      createItems();
    } else if (event.data.action == "setInfoText") {
        $(".info-div").html(event.data.text);
    } else if (event.data.action == "nearPlayers") {
        $("#nearPlayers").html("");

        $.each(event.data.players, function (index, player) {
            $("#nearPlayers").append('<button class="nearbyPlayerButton" data-player="' + player.player + '">' + player.label + ' (' + player.player + ')</button>');
        });

        $("#dialog").dialog("open");

        $(".nearbyPlayerButton").click(function () {
            $("#dialog").dialog("close");
            player = $(this).data("player");
            $.post("http://invhud/GiveItem", JSON.stringify({
                player: player,
                item: event.data.item,
                number: parseInt($("#count").val())
            }));
        });
    }
});

function closeInventory() {
    $.post("http://invhud/NUIFocusOff", JSON.stringify({}));
}

function createItems() {
	$('.item').draggable({
		helper: 'clone',
		appendTo: 'body',
		zIndex: 99999,
		revert: 'invalid',
		start: function (event, ui) {
			if (disabled) {
				return false;
			}
      if (type !== 'normal') {
				$("#drop").addClass("disabled");
				$("#give").addClass("disabled");
				$("#use").addClass("disabled");
      }
			$(this).css('background-image', 'none');
			itemData = $(this).data("item");
			itemInventory = $(this).data("inventory");

			if (itemInventory == "second" || !itemData.canRemove) {
				$("#drop").addClass("disabled");
				$("#give").addClass("disabled");
			}

			if (itemInventory == "second" || !itemData.usable) {
				$("#use").addClass("disabled");
			}
		},
		stop: function () {
			itemData = $(this).data("item");

			if (itemData !== undefined && itemData.name !== undefined) {
				$(this).css('background-image', 'url(\'img/items/' + itemData.name + '.png\'');
				$("#drop").removeClass("disabled");
				$("#use").removeClass("disabled");
				$("#give").removeClass("disabled");
			}
		}
	});
  
  $('.item').mousedown(function (event, ui) {
    if (event.which == 3) {
      console.log('add to hotbar?');
    }
    if (event.which == 1) {
      console.log('you left clicked');
    }
  });
  
  $('.item').dblclick(function (event, ui) {
    itemData = $(this).data("item");

    if (itemData == undefined || itemData.usable == undefined) {
        return;
    }

    itemInventory = $(this).data("inventory");

    if (itemInventory == undefined || itemInventory == "second") {
        return;
    }

    if (itemData.usable) {
        disableInventory(300);
        $.post("http://invhud/UseItem", JSON.stringify({
            item: itemData
        }));
    }
  });
}

function inventorySetup(items) {
  $("#playerInventory").html("");
  $.each(items, function (index, item) {
    count = setCount(item);
    $("#playerInventory").append('<div class="slot"><div id="item-' + index + '" class="item" style = "background-image: url(\'img/items/' + item.name + '.png\')">' +
        '<div class="item-count">' + count + '</div> <div class="item-name">' + item.label + '</div> </div ><div class="item-name-bg"></div></div>');
    $('#item-' + index).data('item', item);
    $('#item-' + index).data('inventory', "main");
  });
}

function secondInventorySetup(items) {
    $("#otherInventory").html("");
    $.each(items, function (index, item) {
        count = setCount(item);

        $("#otherInventory").append('<div class="slot"><div id="itemOther-' + index + '" class="item" style = "background-image: url(\'img/items/' + item.name + '.png\')">' +
            '<div class="item-count">' + count + '</div> <div class="item-name">' + item.label + '</div> </div ><div class="item-name-bg"></div></div>');
        $('#itemOther-' + index).data('item', item);
        $('#itemOther-' + index).data('inventory', "second");
    });
}

function shopInventorySetup(items) {
    $("#otherInventory").html("");
    $.each(items, function (index, item) {
		cost = setCost(item)
		
        $("#otherInventory").append('<div class="slot"><div id="itemOther-' + index + '" class="item" style = "background-image: url(\'img/items/' + item.name + '.png\')">' +
            '<div class="item-count">' + cost + '</div> <div class="item-name">' + item.label + '</div> </div ><div class="item-name-bg"></div></div>');
        $('#itemOther-' + index).data('item', item);
        $('#itemOther-' + index).data('inventory', "second");
    });
}

function Interval(time) {
    var timer = false;
    this.start = function () {
        if (this.isRunning()) {
            clearInterval(timer);
            timer = false;
        }

        timer = setInterval(function () {
            disabled = false;
        }, time);
    };
    this.stop = function () {
        clearInterval(timer);
        timer = false;
    };
    this.isRunning = function () {
        return timer !== false;
    };
}

function disableInventory(ms) {
    disabled = true;

    if (disabledFunction === null) {
        disabledFunction = new Interval(ms);
        disabledFunction.start();
    } else {
        if (disabledFunction.isRunning()) {
            disabledFunction.stop();
        }

        disabledFunction.start();
    }
}

function setCount(item) {
    count = item.count

    if (item.limit > 0) {
        count = item.count + " / " + item.limit
    }

    if (item.type === "item_weapon") {
        if (count == 0) {
            count = "";
        } else {
            count = '<img src="img/bullet.png" class="ammoIcon"> ' + item.count;
        }
    }

    if (item.type === "item_account" || item.type === "item_money") {
        count = formatMoney(item.count);
    }

    return count;
}

function setCost(item) {
    cost = item.price

    if (item.price == 0){
        cost = "Free"
    }
    if (item.price > 0) {
        cost = curIcon + item.price
    }
    return cost;
}

function formatMoney(n, c, d, t) {
    var c = isNaN(c = Math.abs(c)) ? 2 : c,
        d = d == undefined ? "." : d,
        t = t == undefined ? "," : t,
        s = n < 0 ? "-" : "",
        i = String(parseInt(n = Math.abs(Number(n) || 0).toFixed(c))),
        j = (j = i.length) > 3 ? j % 3 : 0;

    return s + (j ? i.substr(0, j) + t : "") + i.substr(j).replace(/(\d{3})(?=\d)/g, "$1" + t);
};

function logIt(value, index, arrawy) {
  console.log(value);
}

$(document).ready(function () {
    $("#count").focus(function () {
        $(this).val("")
    }).blur(function () {
        if ($(this).val() == "") {
            $(this).val("1")
        }
    });

    $("body").on("keyup", function (key) {
        if (Config.closeKeys.includes(key.which)) {
            closeInventory();
        }
    });

    $('#use').droppable({
        hoverClass: 'hoverControl',
        drop: function (event, ui) {
            itemData = ui.draggable.data("item");

            if (itemData == undefined || itemData.usable == undefined) {
                return;
            }

            itemInventory = ui.draggable.data("inventory");

            if (itemInventory == undefined || itemInventory == "second") {
                return;
            }

            if (itemData.usable) {
                disableInventory(300);
                $.post("http://invhud/UseItem", JSON.stringify({
                    item: itemData
                }));
            }
        }
    });

    $('#give').droppable({
        hoverClass: 'hoverControl',
        drop: function (event, ui) {
            itemData = ui.draggable.data("item");

            if (itemData == undefined || itemData.canRemove == undefined) {
                return;
            }

            itemInventory = ui.draggable.data("inventory");

            if (itemInventory == undefined || itemInventory == "second") {
                return;
            }

            if (itemData.canRemove) {
                disableInventory(300);
                $.post("http://invhud/GetNearPlayers", JSON.stringify({
                    item: itemData
                }));
            }
        }
    });

    $('#drop').droppable({
        hoverClass: 'hoverControl',
        drop: function (event, ui) {
            itemData = ui.draggable.data("item");

            if (itemData == undefined || itemData.canRemove == undefined) {
                return;
            }

            itemInventory = ui.draggable.data("inventory");

            if (itemInventory == undefined || itemInventory == "second") {
                return;
            }

            if (itemData.canRemove) {
                disableInventory(300);
                $.post("http://invhud/DropItem", JSON.stringify({
                    item: itemData,
                    number: parseInt($("#count").val())
                }));
            }
        }
    });

    $('#playerInventory').droppable({
        drop: function (event, ui) {
            itemData = ui.draggable.data("item");
            itemInventory = ui.draggable.data("inventory");
            
            if (type === "normal" && itemInventory === "hotbar") {
                disableInventory(500);
                $.post("http://invhud/TakeFromHotbar", JSON.stringify({
                    item: itemData,
                    number: parseInt($("#count").val())
                }));
            }

            if (type === "trunk" && itemInventory === "second") {
                disableInventory(500);
                $.post("http://invhud/TakeFromTrunk", JSON.stringify({
                    item: itemData,
                    number: parseInt($("#count").val())
                }));
			} else if (type === "gbox" && itemInventory === "second") {
                disableInventory(500);
                $.post("http://invhud/TakeFromGBox", JSON.stringify({
                    item: itemData,
                    number: parseInt($("#count").val())
                }));
            } else if (type === "property" && itemInventory === "second") {
                disableInventory(500);
                $.post("http://invhud/TakeFromProperty", JSON.stringify({
                    item: itemData,
                    number: parseInt($("#count").val())
                }));
			} else if (type === "safe" && itemInventory === "second") {
                disableInventory(500);
                $.post("http://invhud/TakeFromSafe", JSON.stringify({
                    item: itemData,
                    number: parseInt($("#count").val())
                }));
			} else if (type === "stash" && itemInventory === "second") {
                disableInventory(500);
                $.post("http://invhud/TakeFromStash", JSON.stringify({
                    item: itemData,
                    number: parseInt($("#count").val())
                }));
            } else if (type === "player" && itemInventory === "second") {
                disableInventory(500);
                $.post("http://invhud/TakeFromPlayer", JSON.stringify({
                    item: itemData,
                    number: parseInt($("#count").val())
                }));
            } else if (type === "shop" && itemInventory === "second") {
                disableInventory(500);
                $.post("http://invhud/TakeFromShop", JSON.stringify({
                    item: itemData,
                    number: parseInt($("#count").val())
                }));
            }
        }
    });
    
    $('#playerHotbar').droppable({
        drop: function (event, ui) {
            itemData = ui.draggable.data("item");
            itemInventory = ui.draggable.data("inventory");

            if (type === "normal" && itemInventory === "main") {
                disableInventory(500);
                console.log('my brain');
                // $.post("http://invhud/PutIntoHotbar", JSON.stringify({
                    // item: itemData,
                    // number: parseInt($("#count").val())
                // }));
            }
        }
    });

    $('#otherInventory').droppable({
        drop: function (event, ui) {
            itemData = ui.draggable.data("item");
            itemInventory = ui.draggable.data("inventory");

            if (type === "trunk" && itemInventory === "main") {
                disableInventory(500);
                $.post("http://invhud/PutIntoTrunk", JSON.stringify({
                    item: itemData,
                    number: parseInt($("#count").val())
                }));
			} else if (type === "gbox" && itemInventory === "main") {
                disableInventory(500);
                $.post("http://invhud/PutIntoGBox", JSON.stringify({
                    item: itemData,
                    number: parseInt($("#count").val())
                }));
            } else if (type === "property" && itemInventory === "main") {
                disableInventory(500);
                $.post("http://invhud/PutIntoProperty", JSON.stringify({
                    item: itemData,
                    number: parseInt($("#count").val())
                }));
			} else if (type === "safe" && itemInventory === "main") {
                disableInventory(500);
                $.post("http://invhud/PutIntoSafe", JSON.stringify({
                    item: itemData,
                    number: parseInt($("#count").val())
                }));
			} else if (type === "stash" && itemInventory === "main") {
                disableInventory(500);
                $.post("http://invhud/PutIntoStash", JSON.stringify({
                    item: itemData,
                    number: parseInt($("#count").val())
                }));
            } else if (type === "player" && itemInventory === "main") {
                disableInventory(500);
                $.post("http://invhud/PutIntoPlayer", JSON.stringify({
                    item: itemData,
                    number: parseInt($("#count").val())
                }));
            } else if (type === "shop" && itemInventory === "main") {
                disableInventory(500);
                $.post("http://invhud/SellToShop", JSON.stringify({
                    item: itemData,
                    number: parseInt($("#count").val())
                }));
            }
        }
    });

    $("#count").on("keypress keyup blur", function (event) {
        $(this).val($(this).val().replace(/[^\d].+/, ""));
        if ((event.which < 48 || event.which > 57)) {
            event.preventDefault();
        }
    });
});

$.widget('ui.dialog', $.ui.dialog, {
    options: {
        // Determine if clicking outside the dialog shall close it
        clickOutside: false,
        // Element (id or class) that triggers the dialog opening 
        clickOutsideTrigger: ''
    },
    open: function () {
        var clickOutsideTriggerEl = $(this.options.clickOutsideTrigger),
            that = this;
        if (this.options.clickOutside) {
            // Add document wide click handler for the current dialog namespace
            $(document).on('click.ui.dialogClickOutside' + that.eventNamespace, function (event) {
                var $target = $(event.target);
                if ($target.closest($(clickOutsideTriggerEl)).length === 0 &&
                    $target.closest($(that.uiDialog)).length === 0) {
                    that.close();
                }
            });
        }
        // Invoke parent open method
        this._super();
    },
    close: function () {
        // Remove document wide click handler for the current dialog
        $(document).off('click.ui.dialogClickOutside' + this.eventNamespace);
        // Invoke parent close method 
        this._super();
    },
});

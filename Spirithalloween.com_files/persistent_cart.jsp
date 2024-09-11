
var positioningEl = "header.header .global-header__container";

var persistentCartCommands = new Array(10);
persistentCartCommands[0] = '/basket/universal_cart.jsp';
persistentCartCommands[1] = '/basket/add_item_pc.cmd';
persistentCartCommands[2] = '/basket/add_items_pc.cmd';
persistentCartCommands[3] = '/basket/delete_item_in_cart.cmd';
persistentCartCommands[4] = '/basket/add_catalog_order_item_pc.cmd';
persistentCartCommands[5] = '/user/add_wishlist_item_to_basket_pc.cmd';
persistentCartCommands[6] = '/user/add_all_wishlist_items_to_basket_pc.cmd';
// Add gift cart into basket command
persistentCartCommands[7] = '/basket/add_item_gc.cmd';
// Add electronic gift certificate into basket command
persistentCartCommands[8] = '/basket/add_item_egc.cmd';

persistentCartCommands[9] = '/basket/add_item_aj.cmd';
// Bopis store selection
persistentCartCommands[10] = '/basket/bopis_item_update.cmd';

var persistentCartContainerId = "#universalcart";
var persistentCartCloseButClass = "#universalcart .close";
var hideTimeOuts= new Array();

var ucartLoadingHTML = 	'<div id="universalcart">' +
				  		'    <div class="content">'+
				  		'	   <div class="loader"><img src="/assets/images/common/loading.gif" alt="Loading..." /></div>' +
				  		'    </div>' +
  				  		'</div>';

var ucartSimpleHTML = 	'<div id="universalcart"></div>';

var persistentCartIsShowing = false;

function showWarningLayer(_message) {
    var a = [];
    a.push('<div id="variantWarningLayer" class="commonLayer layer_wrapper_outer">');
    a.push('<div class="layer_wrapper_inner">');
    a.push(_message);
    a.push('<div class="buttonRow">');
    a.push('<input class="button" type="button" value="OK" onclick="$.colorbox.close()" id="errorContinue" />');
    a.push('</div>');
    a.push('</div>');
    a.push('</div>');
    $.colorbox({
     width:responsiveUtil.getLayerWidth(null, [460,460,310]),
        html:a.join('')
    });
}

function buildMissingVariantMessage(_missingAttrs) {
    var attrLabel = 'variant';
    if (_missingAttrs != null) {
        var attrLabels = _missingAttrs.split('|&|');
        if (attrLabels.length > 0) {
            for(var x = 0; x < attrLabels.length; x++) {
                if (x == 0) {
                    attrLabel = attrLabels[x];
                } else {
                    attrLabel += ' and a ' + attrLabels[x];
                }
            }
        }
    }
    return '<p>Please choose a ' + attrLabel + ' before adding your item(s) to the cart.</p>';
}

function showVariantSelectionWarning(_missingAttrs) {
    var missVarMsg = '<h3><span class="errorIcon"></span>Heads Up! There is something missing</h3><p>Please choose a size/color before adding your item(s) to the cart.</p>';
    if (global.siteCode() == "spt") {
        missVarMsg = '<h3><span class="errorIcon"></span>We&apos;re afraid something is missing</h3><p>Please choose a size/color before adding your item(s) to the cart.</p>';
    }
    showWarningLayer(missVarMsg);
}

/* Function(s) to Show the Basket Layer */
function showBasket(action, params, refreshPage, refreshDelayTime) {
	var requestURL = "";
    let eventAction = "edited"
    let eventContext = "mini-cart"
	if( (action == "show") || (action == "showFromQuickview") || action == "mergeSuccess" || action == "mergeFailed") {
		showloading(ucartLoadingHTML); requestURL = persistentCartCommands[0];
	} else if(action == "addProduct") {
        eventAction = "added"
        eventContext = "quickview"
		showloading(ucartLoadingHTML); requestURL = persistentCartCommands[1];
	} else if(action == "addEnsemble") {
		showloading(ucartLoadingHTML); requestURL = persistentCartCommands[2];
	} else if(action == "remove") {
        eventAction = "removed"
		showloading(ucartLoadingHTML); requestURL = persistentCartCommands[3];
	} else if(action == "addCatalogItems") {
		showloading(ucartLoadingHTML); requestURL = persistentCartCommands[4];
	} else if(action == "addProductWishlist") {
		showloading(ucartLoadingHTML); requestURL = persistentCartCommands[5];
	} else if(action == "addAllProductsWishlist") {
		showloading(ucartLoadingHTML); requestURL = persistentCartCommands[6];
	} else if(action == "addGCProduct") {
		showloading(ucartLoadingHTML); requestURL = persistentCartCommands[7];
	} else if(action == "addEGCProduct") {
		showloading(ucartLoadingHTML); requestURL = persistentCartCommands[8];
	} else if(action == "addProductNew" || action == "addProductNewUpsell") {
        //showloading(ucartLoadingHTML);
        requestURL = persistentCartCommands[9];
    } else if(action == "bopisUpdate") {
        showloading(ucartLoadingHTML); requestURL = persistentCartCommands[10];
    }

	else {
		//console.trace();
	}
    if (window.addToCartOptions !== undefined && window.addToCartOptions.container.textContent.includes("Update Cart")) {
        eventAction = "edited"
    }
    if (window.inMiniCart) {
        eventContext = "mini-cart"
    }
	params = "ts=" + timestamp() + "&action=" + action + "&" + params;

    if(action == "addProductNew" || action == "addProductNewUpsell") {
        var atcBtn = $('#btn-addtocart');
        if (atcBtn[0]) {
            atcBtn.prop('disabled', true);
            atcBtn.addClass('processing');
            atcBtn.text('Adding to Cart...');
        }


        $.ajax({
            type: "POST",
            url: requestURL,
            data: params,
            dataType: "html",
            timeout: 60000,
            success: function (data) {
                hideloading();
                if (atcBtn[0]) {
                    atcBtn.prop('disabled', false);
                    atcBtn.removeClass('processing');
                    atcBtn.addClass('item-added');
                    atcBtn.text('Add to Cart');
                }
                if(action == "addProductNew") {
                    $('#item-added-CompleteLook').html("");
                    $('#item-added-CompleteLook').append(data);
                }if (action == "addProductNewUpsell"){
                    $('#item-added-CompleteLook-upsell').html("");
                    $('#item-added-CompleteLook-upsell').append(data);
                }
                completeTheLook.open();
                atcBtn.removeClass('col-12');
                atcBtn.addClass('col-6');
                $('#btn-checkout').removeClass('a11y-hide');

                
                if (refreshPage != undefined && refreshPage) {
                    if ((action == "mergeSuccess" || action == "mergeFailed")) {
                        var newURL = requestUtil.removeParams(window.location.search, 'merged');
                        setTimeout(function () {
                            location.href = newURL;
                        }, refreshDelayTime || 0);
                    } else {
                        setTimeout(function () {
                            location.reload();
                        }, refreshDelayTime || 0);
                    }
                }
                persistentCartIsShowing = true;
                dispatchCartEvent("added","pdp");
                return true;
            },
            error: function () {
                if (atcBtn[0]) {
                    atcBtn.prop('disabled', false);
                    atcBtn.removeClass('processing');
                    atcBtn.text('Add to Cart');
                }

                hideloading();
                return false;
            }
        });

    }else {
        $.ajax({
            type: "POST",
            url: requestURL,
            data: params,
            dataType: "html",
            timeout: 60000,
            success: function (data) {
                hideloading();
               $(persistentCartContainerId).append(data);
                $(persistentCartContainerId).show();
                if (refreshPage != undefined && refreshPage) {
                    if ((action == "mergeSuccess" || action == "mergeFailed")) {
                        var newURL = requestUtil.removeParams(window.location.search, 'merged');
                        setTimeout(function () {
                            location.href = newURL;
                        }, refreshDelayTime || 0);
                    } else {
                        setTimeout(function () {
                            location.reload();
                        }, refreshDelayTime || 0);
                    }
                }
                persistentCartIsShowing = true;
                if (![persistentCartCommands[0],persistentCartCommands[5],persistentCartCommands[6]].includes(requestURL)) {
                    dispatchCartEvent(eventAction,eventContext);
                } else {
                    let cartBtn = document.querySelector("#universalcart > div > div.totals.clearfix > a")
                    if (cartBtn) {
                        let eventContext = document.body.id;
                        function handleViewCartButton() {
                            localStorage.setItem("mini-cart-action",eventContext);
                        }
                        cartBtn.addEventListener("click",handleViewCartButton)
                    }
                }
                return true;
            },
            error: function () {
                hideloading();
                return false;
            }
        });
    }

}

function showloading(htmlToShow) {
	$(persistentCartContainerId).remove();

	//load, position, show new cart
	$(positioningEl).append(htmlToShow);

	
	if( !$("body").hasClass("checkout")) {
		$(persistentCartContainerId).show();
	}

	// add an event for close layer.
	$(persistentCartCloseButClass).click(function() { hideBasket(); });
}

function hideloading() {
	$(persistentCartContainerId + " *").remove();
	$(persistentCartContainerId).html("");

}


//edit this function to position cart.
function positionpersistentCart() {

    var $cartButton = $('.cartButton');
    var cartTop = $cartButton.position().top;
    var	cartLeft = -10 + ($("body").width() / 2) + ( $("#containerMain").width() / 2 ) - $(persistentCartContainerId).width();


    if(responsiveUtil.isMobile()){
        cartTop = 65;
        cartLeft = 0;
    } else if(responsiveUtil.isTablet()) {
        cartTop = 75;
    }

    $(persistentCartContainerId).css("left", cartLeft+"px");
    $(persistentCartContainerId).css("top", cartTop+"px");

}
  				 
 //edit this function to update the setup
function setupPersistentCartButtons() {
	// draw focus near this
	window.location = "#";

	$(persistentCartCloseButClass).unbind("click").click(function() {
		hideBasket();
	});
	$(persistentCartCloseButClass).attr("href","javascript:void(0)");
	clearAllTimeouts();
}

//Edit this function if need to do something special on basket close.
function hideBasket() {
	$(persistentCartContainerId).hide();
	$(persistentCartContainerId).remove();

	shoppingBagBut = $("#widget-header-active-link").eq(0);
	$(shoppingBagBut).attr("id","");
	$(shoppingBagBut).mouseout();
    let eventContext = document.body.id;
    dispatchMinicartEvent("closed",eventContext)

	persistentCartIsShowing = false;
}

function isShowingBasket() {
	return persistentCartIsShowing;
}

function updateHeader(amt) {
    

	if(amt == 1) {
        $(".js_itemcount").text(amt);
        $("#iconItemCount").text(amt);
    } else {
        $(".js_itemcount").text(amt);
        $("#iconItemCount").text(amt);
    }
}

function addGiftCertificateToCart(prefix, container) {
	addToCart(prefix, container, 'addGCProduct');
}

function addEGCToCart(prefix, container) {
	addToCart(prefix, container, 'addEGCProduct');
}

function addToCart(prefix, container, action, refreshPage) {
    function isQuicklook(_prefix) {
        return _prefix.toLowerCase().indexOf("quicklook") > -1;
    }

    var submitReady = true;
    var missingAttrs = '';
    var params = "";
    var useMissingVariantLayer = false;  /* default is inline missing variant errors */

    var bopisEnabled = true;


    dtmManager.track('cart add');

	// action is a new parameter, so default to the previous behavior
	//action = typeof action !== 'undefined' ? action : 'addProduct';
    action = typeof action !== 'undefined' ? action : 'addProduct';

    if (action == "addProduct" ) {
        useMissingVariantLayer = true;
    } else if (action == "addEnsembleProduct") {
        /* avoid using missing variant layer, then reset this back to addProduct to utilize the right cmd */
        action = "addProduct";
        params += "fromEnsemble=1";
    }

	var scope = $(prefix);
	if (container) {
        var $container = $(container);
        if (useMissingVariantLayer && $container.hasClass("disabled")) {
            submitReady = false;
            missingAttrs = $container.attr('data-unselectedAtts');
        }
		scope = $container.parents(prefix);
	}

	var newAction = $("input[name=newPDPaction]", scope);
	if(newAction[0]) {
        action = newAction.val();
    }

    var productVariantId = $("input[name=productVariantId]", scope).val();
    if (productVariantId == null || productVariantId == undefined) {
        productVariantId = $("input[name=productVariantId2]", scope).val();
    }
    var colorSelectedValue = $("input[name=colorSelectedValue]", scope).val();
    var pickupInStore;
    var sameDayDelivery;
    var isQuickViewSelected;
    if(document.getElementsByClassName('quicklookMiniproduct').length>0) {
        pickupInStore = document.getElementById("quickviewOpt2") ? document.getElementById("quickviewOpt2").checked : false;
        sameDayDelivery = document.getElementById("quickviewOpt3") ? document.getElementById("quickviewOpt3").checked : false;
        isQuickViewSelected = true;
        if(pickupInStore || sameDayDelivery){
            submitReady=true;
        }
    }
     else {
        pickupInStore = document.getElementById("opt2") ? document.getElementById("opt2").checked : false;
        sameDayDelivery = document.getElementById("opt3") ? document.getElementById("opt3").checked : false;
    }
    if (colorSelectedValue == null || colorSelectedValue == undefined) {
        colorSelectedValue = "";
    }
    var sizeSelectedValue = $("input[name=sizeSelectedValue]", scope).val();
    if (sizeSelectedValue == null || sizeSelectedValue == undefined) {
        sizeSelectedValue = "";
    }
    if(pickupInStore || sameDayDelivery){
        if(productVariantId.length <= 0){
            if(isQuickViewSelected){
                productVariantId = $("input[name=qvProductOutOfStockVariantId]", scope).val();
            } else {
                productVariantId = $("input[name=productOutOfStockVariantId]", scope).val();
            }
        }
        if(colorSelectedValue.length <= 0){
            colorSelectedValue = $("input[name=colorOutOfStockSelectedValue]", scope).val();
        }
        if(sizeSelectedValue.length <= 0){
            sizeSelectedValue = $("input[name=sizeOutOfStockSelectedValue]", scope).val();
        }
    }


    if (params != "") {
        params += "&";
    }
    params += "productName=" + $("input[name=productName]", scope).val();
    params += "&productId=" + $("input[name=productId]", scope).val();
    params += "&categoryId=" + $("input[name=categoryId]", scope).val();
    params += "&parentCategoryId=" + $("input[name=parentCategoryId]", scope).val();
    params += "&subCategoryId=" + $("input[name=subCategoryId]", scope).val();
    params += "&shippingOption=" + $('input[name=shippingOption]:checked', scope).val();
    params += "&productVariantId=" + productVariantId;
    params += "&colorSelectedValue=" + colorSelectedValue;
    params += "&sizeSelectedValue=" + sizeSelectedValue;
    params += "&socialMediaUtmSource=" + $("input[name=socialMediaUtmSource]", scope).val();
    if(pickupInStore) {
        params += "&storeNumber=" + $("input[name=storeNumber]", scope).val();
    }
    if (sameDayDelivery) {
        params += "&sameDayStoreNumber=" + $("input[name=sameDayStoreNumber]", scope).val();
    }
    if (action == 'addGCProduct') {
        params += "&quantity=" + $("[name=quantitySelect]", scope).val();
        params += param("purchaserMessage", scope);
    } else if (action == 'addEGCProduct') {
        params += "&quantity=" + $("input[name=quantity]", scope).val();
        params += param("purchaserEmail", scope);
        params += param("purchaserName", scope);
        params += param("recipientEmail", scope);
        params += param("recipientEmailConfirm", scope);
        params += param("recipientName", scope);
        params += param("purchaserMessage", scope);
    } else {
        params += "&quantity=" + $("input[name=quantity]", scope).val();
    }
    if(isQuickViewSelected) {
        if(pickupInStore)
            params += "&quickViewPISSelected=true";
        else
            params += "&quickViewPISSelected=false";
        if(sameDayDelivery)
            params += "&quickViewSDDSelected=true";
        else
            params += "&quickViewSDDSelected=false";
    }
    //see if this is an update.
    var objItemGUID = $("input[name=itemGUID]", scope);
    if (objItemGUID.val() !== "" && objItemGUID.val() != undefined) {
        params += "&itemGUID=" + $("input[name=itemGUID]", scope).val() + "&isUpdate=1";
    }

    if ($("input[name=onBasketPage]", scope).length > 0) {
        params += "&onBasketPage=" + $("input[name=onBasketPage]", scope).val();
    }

    if (prefix != undefined) {
        params += "&prefix=" + prefix;
    }

    if (action == "addProductNew" || action == "addProductNewUpsell"){
        var qnt= $("input[name=quantity]", scope).val();
        if (qnt== undefined){
            qnt=0;
        }
        if(qnt<1 || qnt > 99){
            setTimeout( function() { resetErrorGeneral(); }, 1);
        setTimeout( function() { resetErrorFields(); }, 1);
            setTimeout( function() { errorAppend((prefix + " #error-quantity"),"Please enter a quantity between 1 and 99.");}, 1);
       return;
        }
    }

    //persistentCartIsShowing = false;
    /* START - AJAX VARIANT MATRIX UPDATE - new function in common.js */
    //updateStoreFromColorBox();
    /* END - AJAX VARIANT MATRIX UPDATE */
    //alert('showing basket');
    //showBasket(action, params, refreshPage);
    var pickupStoreEligible = false;
    var isDefaultStore = false;
    if($("input[name=pickupStoreEligible]").length > 0 && $("input[name=pickupStoreEligible]").val() == 'true'){
        pickupStoreEligible = true;
    }
    if((document.getElementsByClassName('quicklookMiniproduct').length>0)
        && ($('#quickviewOpt2') && $('#quickviewOpt2').is(':checked') && $("#qvYourStoreContainerNameId").html().length <= 0)) {
        isDefaultStore = true;
    }
    else if (($('#opt2') && $('#opt2').is(':checked') && $("input[name=UserStoreName]").val().length <= 0)) {
        isDefaultStore = true;
    }
    if (!submitReady || (pickupInStore && (pickupStoreEligible || isDefaultStore))) {
        $container.addClass("outOfStock");
        if(pickupStoreEligible){
            document.getElementById("storeHeading").scrollIntoView({behavior: "smooth",block: "center"})
        }else if(isDefaultStore){
            $('#storeHeading').addClass('common-error');

            $('.js_variantSelectInput').each(function(index,item){
                if($(item).val() != "" && $(item).val().length > 0 ){
                }else{
                    $(item).addClass('outOfStock');
                }
            });

            $('#storeHeading').show();
            document.getElementById("storeHeading").scrollIntoView({behavior: "smooth",block: "center"})
        }else {
            if (useMissingVariantLayer) {
                if($('#colorbox').is(':visible'))
                    setQuickViewVariantSelectionError();
                else
                    setVariantSelectionError();
                if (bopisEnabled) {
                    if(document.getElementsByClassName('quicklookMiniproduct').length>0){
                        if ($('#quickviewOpt2').is(':checked')) {
                            $('#variantErrorPS').show();
                            $('#quickviewPickupPanel').addClass('error-panel');
                            document.getElementById("quickviewPickupPanel").scrollIntoView({behavior: "smooth",block: "center"})
                        } else {
                            $('#quickviewPanelSM label.error-panel').hide();
                            $('#qvVariantAvailableSP').hide();
                            $('#qvVariantErrorSP').show();
                            document.getElementById("qvVariantErrorSP").scrollIntoView({behavior: "smooth",block: "center"})
                        }
                    } else {
                        if ($('#opt2').is(':checked')) {
                            $('#variantErrorPS').show();
                            $('#pickupPanel').addClass('error-panel');
                            document.getElementById("product-attributes").scrollIntoView({ behavior: "smooth", block: "center" });
                        } else {
                            $('#panelSM label.error-panel').hide();
                            $('#variantAvailableSP').hide();
                            $('#variantErrorSP').show();
                            document.getElementById("product-attributes").scrollIntoView({ behavior: "smooth", block: "center" });
                        }
                    }
                } else {
                    if(!document.getElementsByClassName('quicklookMiniproduct').length>0){
                        document.getElementById("product-attributes").scrollIntoView({ behavior: "smooth", block: "center" });
                    }
                }
            } else {
                $('.js_variantSelectInput').each(function(index,item){
                    if($(item).val() != "" && $(item).val().length > 0 ){
                    }else{
                        $(item).addClass('outOfStock');
                    }
                });
                /* inline missing variant error */
                errorAppend(prefix + " .common-error", buildMissingVariantMessage(missingAttrs));
            }
        }
    }else{
        if(bopisEnabled == true) {
            var storename = $("input[name=UserStoreName]").val();
            $('#variantError').hide();
            if(typeof storename != "undefined") {
                if (storename.length > 0) {
                    $('#storeHeadingCS').show();
                    $('#storeHeadingCS').text("Select item Size/Color for Availability");
                }
            }
            

        }
        window.addToCartOptions = {
            prefix: prefix ? prefix : null,
            container: container ? container : null,
            action: action ? action : null
        }
        showBasket(action, params, refreshPage);
    }
}

function param(paramName, scope) {
	return "&"+paramName+"=" + encodeURI($("[name="+paramName+"]", scope).val());
}

function wishListAddToCart(params,refreshPage,refreshDelayTime) {
	showBasket('addProductWishlist',params,refreshPage,refreshDelayTime);
    dispatchWishlistEvent("moved","account")
}

function wishListAddAllToCart(params,refreshPage,refreshDelayTime) {
	showBasket('addAllProductsWishlist',params,refreshPage,refreshDelayTime);
    dispatchWishlistEvent("moved-all","account")
}

function addCatalogOrderItemsToCart() {
    params = "";
	params += "productId=" + $("input[name=productId]").val();
	params += "&itemNumber=" + $("input[name=itemNumber]").val();
	params += "&productName=" + $("input[name=productName]").val();
	params += "&productVariantId=" + $("input[name=productVariantId]").val();
	params += "&quantity=" + $("input[name=quantity]").val();
	params += "&colorSelectedValue=" + $("input[name=colorSelectedValue]").val();
	params += "&sizeSelectedValue=" + $("input[name=sizeSelectedValue]").val();
    showBasket('addCatalogItems',params);
}

function ensembleHasQty() {
    var itemsQty = 0;
    $('[name=quantity].variantParam').each(function(){
        if ($(this).val() > 0) {
            itemsQty += $(this).val();
            return false;
        }
    });
    return (itemsQty > 0);
}

function addEnsembleToCart(type) {
	if(type == 'all') {
		$('[name=quantity].variantParam').val("1");
	}



    var variantParamsObjs = [];

    $('.productParam, .submitReady .variantParam').each(function(){
        /* reverse the order */
        //variantParamsObjs.unshift(this);
        variantParamsObjs.push(this);
    });
	var params = "" + $(variantParamsObjs).serialize();

	
	$('.submitReady input[name^=shippingOption]:checked').each(function(i,o){
       params+="&shippingOption=" + $(o).val();
    });

    $('.submitReady input[name=productId]').each(function(i,o){
        params+="&productId=" + $(o).val();
    });
    $('.submitReady input[name=productVariantIndex]').each(function(i,o){
        params+="&productVariantIndex=" + $(o).val();
    });


	params += "&productCount=" + $('[name=quantity].variantParam').length;

	persistentCartIsShowing = false;
	showBasket('addEnsemble',params);
}

// Edit this per site to adjust location
function adjustDivLocation(divToAdjust) {
	var bWindowOffsets = getScrollXY();
	var bWindowViewport = getViewportSize();
	var qvTop = ((bWindowViewport[1] / 2) - ($(divToAdjust).height() / 2)) + bWindowOffsets[1];
	qvTop = (qvTop < 0) ? 100 : qvTop;
	$(divToAdjust).css("top",qvTop+"px");
	$(divToAdjust).css("left","50%");
	$(divToAdjust).css("margin-left",-($(divToAdjust).width()/2));
}

// Helper Function(s)
function getScrollXY() {
  var scrOfX = 0, scrOfY = 0;
  if( typeof( window.pageYOffset ) == 'number' ) {
    //Netscape compliant
    scrOfY = window.pageYOffset;
    scrOfX = window.pageXOffset;
  } else if( document.body && ( document.body.scrollLeft || document.body.scrollTop ) ) {
    //DOM compliant
    scrOfY = document.body.scrollTop;
    scrOfX = document.body.scrollLeft;
  } else if( document.documentElement && ( document.documentElement.scrollLeft || document.documentElement.scrollTop ) ) {
    //IE6 standards compliant mode
    scrOfY = document.documentElement.scrollTop;
    scrOfX = document.documentElement.scrollLeft;
  }
  return [ scrOfX, scrOfY ];
}

function getViewportSize() {
  var vpW = 0, vpH = 0;
  if (typeof window.innerWidth != 'undefined')
  {
    vpW = window.innerWidth,
    vpH = window.innerHeight;
  }
  else if (typeof document.documentElement != 'undefined' && typeof document.documentElement.clientWidth != 'undefined' && document.documentElement.clientWidth != 0)
  {
    vpW = document.documentElement.clientWidth,
    vpH = document.documentElement.clientHeight;
  }
  else
  {
    vpW = document.getElementsByTagName('body')[0].clientWidth,
    vpH = document.getElementsByTagName('body')[0].clientHeight;
  }
  return [  vpW, vpH ];
}

function errorAppend(area,msg) {
	$(area).html(msg.replace(/&amp;/g, "&").replace(/&lt;/g,
        "<").replace(/&gt;/g, ">").replace(/&#39;/g, "'"));
	$(area).show().next('.variant').addClass('variantInError');
}

function resetErrorFields() {
    //$(".common-error").hide().html("");
    $(".common-error").not("#universalcart .common-error").not(".radioinfo-container .common-error").hide().html("");
    $(".variantInError").removeClass("variantInError");
}

function messageAppend(area,msg) {
	$(area).html(msg);
	$(area).show();
}

function resetMessageFields() {
	$(".glo-tex-info").hide();
}

function resetErrorGeneral() {
    $(".error-general").empty();
}

function clearAllTimeouts() {
	for(x = 0; x < hideTimeOuts.length; x++)
	{ clearTimeout(hideTimeOuts[x]); }
}

function timestamp() { 
	return new Date().getTime(); 
}

function hideQuickView() {
    $.colorbox.close();
}

function loadOverlay(overlay, overlayURL) {
	if (typeof $("#overlay_wrap").Overlay != "undefined") {
		$("#overlay_wrap").Overlay.show(overlay, null, { sourceURL : overlayURL });
    }
}

function showEnsemblePageColorSizeError() {
    setTimeout( function() { errorAppend("#error-page-notification", '<div class="error-item"><div class="errorIconBG bigger"><h3>You&apos;re Almost There</h3><p>Please choose a size/color for the item(s) below.</p></div></div>');$(window).scrollTop($("#error-page-notification").offset().top);}, 1);
    //$(window).scrollTop($("#error-page-notification").offset().top);
}

function showEnsemblePageQuantityError() {
    setTimeout( function() { errorAppend("#error-page-notification", '<div class="error-item"><div class="errorIconBG bigger"><h3>You&apos;re Almost There</h3><p>Please enter the number of items you would like below.</p></div></div>');$(window).scrollTop($("#error-page-notification").offset().top);}, 1);
    //$(window).scrollTop($("#error-page-notification").offset().top);
}

function showEnsemblePageError() {
    setTimeout( function() { errorAppend("#error-page-notification", '<div class="error-item"><div class="errorIconBG bigger"><h3>You&apos;re Almost There</h3><p>Please select at least one quantity and color/size option for the item(s) below.</p></div></div>');$(window).scrollTop($("#error-page-notification").offset().top);}, 1);
    //$(window).scrollTop($("#error-page-notification").offset().top);
}

$(document).on("click",function(event) {
    var posX = event.clientX;
    var posY = event.clientY;
    var miniCart = $('#universalcart');
    var miniCartPos = miniCart.offset();
    if (miniCartPos && isShowingBasket()) {
        // If user click to background, close the mini cart
        if (!(posX >= miniCartPos.left && posX <= (miniCartPos.left + miniCart.width()) && posY >= miniCartPos.top && posY <= (miniCartPos.top + miniCart.height()))) {
            hideBasket();
        }
    }
});
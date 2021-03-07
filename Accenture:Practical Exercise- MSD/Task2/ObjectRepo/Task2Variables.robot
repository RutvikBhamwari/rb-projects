*** Variables ***

${AMAZON_HEADING}          //a[contains(@class,'nav-logo-link nav-progressive-attribute')]
${SEARCH_TEXTBOX}          //input[contains(@id,'twotabsearchtextbox')]
${SEARCHED_RESULT}         //span[contains(@class,'a-color-state a-text-bold')]
${SORT_CLICK}              //span[contains(@class,'a-button-text a-declarative')]
${HIGH_TO_LOW_OPTION}      //a[text()='Price: High to Low']
${ADD_CART}                //input[contains(@value,'Add to Cart')]
${ITEM_INFO}               //h1[contains(text(),'About this item')]
${SELECT_PRODUCT}          //span[contains(@class,'a-size-medium a-color-base a-text-normal')][text()='${textToReplace}']
${PRODUCT_DISPLAY_HEAD}    //span[contains(@class,'a-size-medium a-color-base a-text-normal')]
${ADDED_CART}              //h1[contains(text(),'Added to Cart')]

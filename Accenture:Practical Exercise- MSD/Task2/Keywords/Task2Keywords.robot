*** Settings ***
Documentation    This page is having keyword related Task 2 where we are searching costly products and adding it in cart. 
Library      SeleniumLibrary
Library    String    

Resource    CommanKeywords.robot

*** Keywords ***

Verified Amazon Landing Home Page Opened
    Page Should Contain Element    ${AMAZON_HEADING} 
    
Search for a Category
    [Arguments]    ${category}
    Scroll Element Into View    ${SEARCH_TEXTBOX}
    Click Element    ${SEARCH_TEXTBOX}    
    Input Text    ${SEARCH_TEXTBOX}    ${category}
    Press Keys    None    RETURN
    
List Of Product Displayed    
    Page Should Contain Element    ${SEARCHED_RESULT}  
    Click Element    ${SORT_CLICK}    
    Wait Until Element Is Visible    ${HIGH_TO_LOW_OPTION}     
    Click Element    ${HIGH_TO_LOW_OPTION}   
    
First Product Added TO Cart 
    [Arguments]    ${firstProductToSelect}   
    Wait Until Element Is Visible    ${PRODUCT_DISPLAY_HEAD}
    ${firstProductAdded}    Replace String    ${SELECT_PRODUCT}    ${textToReplace}    ${firstProductToSelect}    
    Click Element      ${firstProductAdded}         
    Add Product TO Cart
    
Add Product TO Cart     
    Wait Until Element Is Visible    ${ITEM_INFO}
    Scroll Element Into View    ${ADD_CART}
    Click Element    ${ADD_CART}   
    Wait Until Element Is Visible   ${ADDED_CART}
    
Second Product Added To Cart
   [Arguments]    ${secondProductToSelect}    ${category}
   Search for a Category     ${category}    
   List Of Product Displayed
    Wait Until Element Is Visible    ${PRODUCT_DISPLAY_HEAD}
    ${firstProductAdded}    Replace String    ${SELECT_PRODUCT}    ${textToReplace}    ${secondProductToSelect}    
    Click Element      ${firstProductAdded} 
    Add Product TO Cart
    
     
*** Settings ***  
Documentation    Test Suit to verify that the user is able to login and verifying user role functionlity
Library          SeleniumLibrary
Resource    ../Keywords/CommanKeywords.robot

Test Setup    Open URL    
# Test Teardown    Logout from Application


*** Test Cases ***
Search For Product Category And Add Products In Cart
    Verified Amazon Landing Home Page Opened
    Search for a Category    ${category}
    List Of Product Displayed
    First Product Added TO Cart     ${firstProductToSelect}
    Second Product Added To Cart    ${secondProductToSelect}    ${category}
*** Settings ***
Library      SeleniumLibrary
Resource    ../TestData/Task2Testdata.robot
Resource   ../ObjectRepo/Task2Variables.robot
Resource   ../Keywords/Task2Keywords.robot

*** Keywords ***

Open URL
    Open Browser   ${url}   ${browser}
    Maximize Browser Window 
    Set Browser Implicit Wait    ${implicitWait}
    
Logout from Application
    Close Browser
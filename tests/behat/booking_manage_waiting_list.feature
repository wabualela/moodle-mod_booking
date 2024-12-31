@mod @mod_booking @booking_manage_waiting_list
Feature: In a course add a booking option and manage its waiting list
  As an administrator or a teacher
  I need to manage waiting list and booked students of booking option

  Background:
    Given the following "custom profile fields" exist:
      | datatype | shortname     | name         |
      | text     | userpricecat  | userpricecat |
    And I clean booking cache
    And the following "mod_booking > pricecategories" exist:
      | ordernum | identifier | name  | defaultvalue | disabled | pricecatsortorder |
      | 1        | default    | Price | 55           | 0        | 1                 |
      | 2        | discount1  | Disc1 | 44           | 0        | 2                 |
    And the following "users" exist:
      | username | firstname | lastname | email                | idnumber | profile_field_userpricecat |
      | teacher1 | Teacher   | 1        | teacher1@example.com | T1       |                            |
      | admin1   | Admin     | 1        | admin1@example.com   | A1       |                            |
      | student1 | Student   | 1        | student1@example.com | S1       |                            |
      | student2 | Student   | 2        | student2@example.com | S2       |                            |
      | student3 | Student   | 3        | student3@example.com | S3       | discount1                  |
      | student4 | Student   | 4        | student4@example.com | S4       |                            |
      | student5 | Student   | 5        | student5@example.com | S5       |                            |
    And the following "courses" exist:
      | fullname | shortname | category | enablecompletion |
      | Course 1 | C1        | 0        | 1                |
    And the following "course enrolments" exist:
      | user     | course | role           |
      | teacher1 | C1     | editingteacher |
      | teacher1 | C1     | manager        |
      | student1 | C1     | student        |
      | student2 | C1     | student        |
      | student3 | C1     | student        |
      | student4 | C1     | student        |
      | student5 | C1     | student        |
    And the following "core_payment > payment accounts" exist:
      | name           |
      | Account1       |
    And the following "local_shopping_cart > payment gateways" exist:
      | account  | gateway | enabled | config                                                                                |
      | Account1 | paypal  | 1       | {"brandname":"Test paypal","clientid":"Test","secret":"Test","environment":"sandbox"} |
    And the following "local_shopping_cart > plugin setup" exist:
      | account  | cancelationfee |
      | Account1 | 0              |
    And the following "local_shopping_cart > user credits" exist:
      | user     | credit | currency |
      | student2 | 150    | EUR      |
      | student3 | 200    | EUR      |
    And the following "activities" exist:
      | activity | course | name       | intro                  | bookingmanager | eventtype | cancancelbook |
      | booking  | C1     | My booking | My booking description | teacher1       | Webinar   | 1             |
    And I change viewport size to "1366x10000"

  @javascript
  Scenario: Booking option: reorder waiting list
    Given the following "mod_booking > options" exist:
      | booking    | text                 | course | description  | teachersforoption | maxanswers | maxoverbooking | datesmarker | optiondateid_1 | daystonotify_1 | coursestarttime_1 | courseendtime_1 | waitforconfirmation |
      | My booking | Option: waiting list | C1     | Waiting list | teacher1          | 5          | 5              | 1           | 0              | 0              | ## tomorrow ##    | ## +2 days ##   | 1                   |
    Given I am on the "My booking" Activity page logged in as teacher1
    And I click on "Settings" "icon" in the ".allbookingoptionstable_r1" "css_element"
    And I click on "Book other users" "link" in the ".allbookingoptionstable_r1" "css_element"
    And I click on "Student 1 (student1@example.com)" "text"
    And I click on "Student 2 (student2@example.com)" "text"
    And I click on "Student 3 (student3@example.com)" "text"
    When I click on "Add" "button"
    ## Book 2 students
    And I click on the element with the number "3" with the dynamic identifier "waitinglist" and action "confirmbooking"
    And I wait "1" seconds
    And I click on "Book" "button" in the ".modal-footer" "css_element"
    ## And I wait until the page is ready
    And I wait "1" seconds
    And I click on the element with the number "2" with the dynamic identifier "waitinglist" and action "confirmbooking"
    And I wait "1" seconds
    And I click on "Book" "button" in the ".modal-footer" "css_element"
    And I wait until the page is ready
    Then I should see "Student 1 (student1@example.com)" in the ".userselector #removeselect" "css_element"
    And I should see "Student 2 (student2@example.com)" in the ".userselector #removeselect" "css_element"
    ## Add 2 more students
    And I click on "Student 4 (student4@example.com)" "text"
    And I click on "Student 5 (student5@example.com)" "text"
    When I click on "Add" "button"
    ## Verify location
    And I should see "student3@example.com" in the "//tr[contains(@id, 'waitinglist') and contains(@id, '_r1')]" "xpath_element"
    And I should see "student5@example.com" in the "//tr[contains(@id, 'waitinglist') and contains(@id, '_r2')]" "xpath_element"
    ## Resort rows
    And I drag "//tr[contains(@id, '_r2')]//span[@data-drag-type='move']" "xpath_element" and I drop it in "//tr[contains(@id, '_r1')]//span[@data-drag-type='move']" "xpath_element"
    And I should see "student5@example.com" in the "//tr[contains(@id, 'waitinglist') and contains(@id, '_r1')]" "xpath_element"

  @javascript
  Scenario: Booking option: waiting list with prices
    Given the following config values are set as admin:
      | config             | value        | plugin  |
      | pricecategoryfield | userpricecat | booking |
    And the following "mod_booking > options" exist:
      | booking    | text                    | course | description  | teachersforoption | useprice | maxanswers | maxoverbooking | datesmarker | optiondateid_1 | daystonotify_1 | coursestarttime_1 | courseendtime_1 | waitforconfirmation |
      | My booking | Waiting_list_with_price | C1     | Waiting list | teacher1          | 1        | 2          | 3              | 1           | 0              | 0              | ## tomorrow ##    | ## +2 days ##   | 1                   |
    And the following "mod_booking > answers" exist:
      | booking    | option                  | user     |
      | My booking | Waiting_list_with_price | student1 |
      | My booking | Waiting_list_with_price | student2 |
    And I am on the "My booking" Activity page logged in as student3
    And I should see "44.00 EUR" in the ".allbookingoptionstable_r1" "css_element"
    And I click on "Book it - on waitinglist" "text" in the ".allbookingoptionstable_r1" "css_element"
    And I should see "You are on the waiting list" in the ".allbookingoptionstable_r1" "css_element"
    And I log out
    And I am on the "My booking" Activity page logged in as student4
    And I should see "55.00 EUR" in the ".allbookingoptionstable_r1" "css_element"
    And I click on "Book it - on waitinglist" "text" in the ".allbookingoptionstable_r1" "css_element"
    And I should see "You are on the waiting list" in the ".allbookingoptionstable_r1" "css_element"
    And I log out
    When I am on the "My booking" Activity page logged in as teacher1
    And I click on "Settings" "icon" in the ".allbookingoptionstable_r1" "css_element"
    And I click on "Book other users" "link" in the ".allbookingoptionstable_r1" "css_element"
    And I wait until the page is ready
    ## Confirm all 4 students' bookings
    And I click on the element with the number "4" with the dynamic identifier "waitinglist" and action "confirmbooking"
    And I wait until the page is ready
    And I click on "Book" "button" in the ".modal-footer" "css_element"
    And I wait until the page is ready
    And I click on the element with the number "3" with the dynamic identifier "waitinglist" and action "confirmbooking"
    And I wait until the page is ready
    And I click on "Book" "button" in the ".modal-footer" "css_element"
    And I wait until the page is ready
    And I click on the element with the number "2" with the dynamic identifier "waitinglist" and action "confirmbooking"
    And I wait until the page is ready
    And I click on "Book" "button" in the ".modal-footer" "css_element"
    And I wait until the page is ready
    And I click on the element with the number "1" with the dynamic identifier "waitinglist" and action "confirmbooking"
    And I wait until the page is ready
    And I click on "Book" "button" in the ".modal-footer" "css_element"
    And I wait until the page is ready
    And I log out
    ## Add booking options to cart for students 1 and 2
    And I am on the "My booking" Activity page logged in as student1
    And I click on "Add to cart" "text" in the ".allbookingoptionstable_r1 .booknow" "css_element"
    And I wait until the page is ready
    And I log out
    And I am on the "My booking" Activity page logged in as student2
    And I click on "Add to cart" "text" in the ".allbookingoptionstable_r1 .booknow" "css_element"
    And I wait until the page is ready
    And I log out
    ## Admin confirms purchase of bi=ooking option by students 1 and 2
    And I log in as "admin"
    And I visit "/local/shopping_cart/cashier.php"
    And I wait until the page is ready
    And I set the field "Select a user..." to "student1"
    And I click on "Continue" "button"
    And I should see "Waiting_list_with_price" in the "#shopping_cart-cashiers-cart" "css_element"
    And I click on "Proceed to checkout" "text" in the ".card-body" "css_element"
    And I wait until the page is ready
    And I click on "Confirm cash payment" "text" in the ".card-body" "css_element"
    And I click on "Next customer" "text"
    And I set the field "Select a user..." to "student2"
    And I click on "Continue" "button"
    And I should see "Waiting_list_with_price" in the "#shopping_cart-cashiers-cart" "css_element"
    And I click on "Proceed to checkout" "text" in the ".card-body" "css_element"
    And I wait until the page is ready
    And I click on "Confirm cash payment" "text" in the ".card-body" "css_element"
    And I log out
    ## Validate waiting list for student 3
    And I am on the "My booking" Activity page logged in as student3
    And I should see "You are on the waiting list" in the ".allbookingoptionstable_r1" "css_element"
    And I should see "(Waiting list: 2/3)" in the ".allbookingoptionstable_r1" "css_element"
    And I log out
    ## Cancel booking for student 2
    Then I am on the "My booking" Activity page logged in as teacher1
    And I click on "Settings" "icon" in the ".allbookingoptionstable_r1" "css_element"
    And I click on "Book other users" "link" in the ".allbookingoptionstable_r1" "css_element"
    And I click on "Student 2 (student2@example.com)" "text"
    And I click on "Remove" "button"
    ## Cancel waiting list for student 4
    And I click on the element with the number "1" with the dynamic identifier "waitinglist" and action "unconfirmbooking"
    And I wait until the page is ready
    And I click on "Book" "button" in the ".modal-footer" "css_element"
    And I log out
    ## Validate availability and buy option as student 3
    And I am on the "My booking" Activity page logged in as student3
    And I click on "Add to cart" "text" in the ".allbookingoptionstable_r1 .booknow" "css_element"
    And I wait until the page is ready
    And I visit "/local/shopping_cart/checkout.php"
    And I should see "Waiting_list_with_price" in the ".shopping-cart-checkout-items-container" "css_element"
    ##And I should see "44.00 EUR" in the ".shopping-cart-checkout-items-container" "css_element"
    And I should see "44.00 EUR" in the ".sc_price_label .sc_initialtotal" "css_element"
    And I should see "Use credit: 200.00 EUR" in the ".sc_price_label .sc_credit" "css_element"
    And I should see "44.00 EUR" in the ".sc_price_label .sc_deductible" "css_element"
    And I should see "156.00 EUR" in the ".sc_price_label .sc_remainingcredit" "css_element"
    And I should see "0 EUR" in the ".sc_totalprice" "css_element"
    And I press "Checkout"
    And I wait "1" seconds
    And I press "Confirm"
    And I wait until the page is ready
    And I should see "Payment successful!"
    And I log out
    ## Validate that student 4 still on waiting list with only cancellation possible
    And I am on the "My booking" Activity page logged in as student4
    And I should see "You are on the waiting list" in the ".allbookingoptionstable_r1" "css_element"
    And I should see "Undo my booking" in the ".allbookingoptionstable_r1" "css_element"
    And I should see "(Waiting list: 1/3)" in the ".allbookingoptionstable_r1" "css_element"

<?php
// This file is part of Moodle - http://moodle.org/
//
// Moodle is free software: you can redistribute it and/or modify
// it under the terms of the GNU General Public License as published by
// the Free Software Foundation, either version 3 of the License, or
// (at your option) any later version.
//
// Moodle is distributed in the hope that it will be useful,
// but WITHOUT ANY WARRANTY; without even the implied warranty of
// MERCHANTABILITY or FITNESS FOR A PARTICULAR PURPOSE.  See the
// GNU General Public License for more details.
//
// You should have received a copy of the GNU General Public License
// along with Moodle.  If not, see <http://www.gnu.org/licenses/>.

/**
 * Control and manage booking dates.
 *
 * @package mod_booking
 * @copyright 2023 Wunderbyte GmbH <info@wunderbyte.at>
 * @license http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */

namespace mod_booking\option\fields;

use mod_booking\booking_option_settings;
use mod_booking\option\fields_info;
use mod_booking\option\field_base;
use mod_booking\utils\wb_payment;
use MoodleQuickForm;
use stdClass;

/**
 * Class to handle one property of the booking_option_settings class.
 *
 * Coursestarttime is fully replaced with the optiondates class.
 * Its only here as a placeholder.
 *
 * @copyright Wunderbyte GmbH <info@wunderbyte.at>
 * @author Georg Maißer
 * @license http://www.gnu.org/copyleft/gpl.html GNU GPL v3 or later
 */
class coursestarttime extends field_base {
    /**
     * This ID is used for sorting execution.
     * @var int
     */
    public static $id = MOD_BOOKING_OPTION_FIELD_COURSESTARTTIME;

    /**
     * Some fields are saved with the booking option...
     * This is normal behaviour.
     * Some can be saved only post save (when they need the option id).
     * @var int
     */
    public static $save = MOD_BOOKING_EXECUTION_NORMAL;

    /**
     * This identifies the header under which this particular field should be displayed.
     * @var string
     */
    public static $header = MOD_BOOKING_HEADER_DATES;

    /**
     * An int value to define if this field is standard or used in a different context.
     * @var array
     */
    public static $fieldcategories = [MOD_BOOKING_OPTION_FIELD_STANDARD];

    /**
     * Additionally to the classname, there might be others keys which should instantiate this class.
     * @var array
     */
    public static $alternativeimportidentifiers = [];

    /**
     * This is an array of incompatible field ids.
     * @var array
     */
    public static $incompatiblefields = [];

    /**
     * This function adds error keys for form validation.
     * @param array $data
     * @param array $files
     * @param array $errors
     * @return array
     */
    public static function validation(array $data, array $files, array &$errors) {

        return $errors;
    }

    /**
     * This function interprets the value from the form and, if useful...
     * ... relays it to the new option class for saving or updating.
     * @param stdClass $formdata
     * @param stdClass $newoption
     * @param int $updateparam
     * @param ?mixed $returnvalue
     * @return array // If no warning, empty array.
     */
    public static function prepare_save_field(
        stdClass &$formdata,
        stdClass &$newoption,
        int $updateparam,
        $returnvalue = null
    ): array {
        if (!empty($formdata->selflearningcourse)) {
            return parent::prepare_save_field($formdata, $newoption, $updateparam, $returnvalue);
        } else {
            return [];
        }
    }

    /**
     * Standard function to transfer stored value to form.
     * @param stdClass $data
     * @param booking_option_settings $settings
     * @return void
     * @throws dml_exception
     */
    public static function set_data(stdClass &$data, booking_option_settings $settings) {
        if (!empty($settings->selflearningcourse)) {
            parent::set_data($data, $settings);
        } else {
            return;
        }
    }

    /**
     * Instance form definition
     * @param MoodleQuickForm $mform
     * @param array $formdata
     * @param array $optionformconfig
     * @param array $fieldstoinstanciate
     * @param bool $applyheader
     * @return void
     */
    public static function instance_form_definition(
        MoodleQuickForm &$mform,
        array &$formdata,
        array $optionformconfig,
        $fieldstoinstanciate = [],
        $applyheader = true
    ) {
        global $CFG;
        // Standardfunctionality to add a header to the mform (only if its not yet there).
        if ($applyheader) {
            fields_info::add_header_to_mform($mform, self::$header);
        }

        // Check if config setting for self-learning courses is active.
        if (wb_payment::pro_version_is_activated()) {
            $selflearningcourseactive = (int)get_config('booking', 'selflearningcourseactive');
        } else {
            $selflearningcourseactive = 0;
        }

        $selflearningcourselabel = get_string('selflearningcourse', 'mod_booking');
        // The label can be overwritten in plugin config.
        if (!empty(get_config('booking', 'selflearningcourselabel'))) {
            $selflearningcourselabel = get_config('booking', 'selflearningcourselabel');
        }

        if ($selflearningcourseactive === 1) {
            $mform->addElement(
                'static',
                'selflearningcoursecoursestarttimealert',
                '',
                '<div class="alert alert-light">' .
                    get_string('selflearningcoursecoursestarttimealert', 'mod_booking', $selflearningcourselabel) .
                '</div>'
            );
            $mform->hideIf('selflearningcoursecoursestarttimealert', 'selflearningcourse', 'neq', 1);
        }

        $mform->addElement(
            'date_time_selector',
            'coursestarttime',
            get_string('selflearningcoursecoursestarttime', 'mod_booking')
        );
        $mform->setType('coursestarttime', PARAM_INT);
        $mform->addHelpButton(
            'coursestarttime',
            'selflearningcoursecoursestarttime',
            'mod_booking',
            '',
            false,
            $selflearningcourselabel
        );
        $mform->hideIf('coursestarttime', 'selflearningcourse', 'neq', 1);
    }
}

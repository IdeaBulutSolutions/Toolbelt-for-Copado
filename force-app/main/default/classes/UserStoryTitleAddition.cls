/**
 * Adds the value of a configurable User Story field (by default the Jira key) to the start or the end of the
 * user story title, for example "[PROJ-1234] Add new object" or "Add new object [PROJ-1234]".
 *
 * Configured by the Default record of Toolbelt_Setting__mdt. The source field is read by its API name, so the
 * package does not depend on the package that owns the field (for example copadoccmint).
 */
public with sharing class UserStoryTitleAddition {

    private static final String MODE_SUFFIX = 'Suffix';
    private static final Integer MAX_TITLE_LENGTH =
        Schema.SObjectType.copado__User_Story__c.fields.copado__User_Story_Title__c.getLength();

    @TestVisible
    private static String settingName = 'Default';

    /** Lets tests run without depending on the values of the org's Default record. */
    @TestVisible
    private static Settings settingsOverride;

    public static void apply(List<copado__User_Story__c> stories, Map<Id, copado__User_Story__c> oldStories) {
        Settings settings = settingsOverride != null ? settingsOverride : loadSettings(settingName);
        if (settings == null || !settings.enabled || !isUserStoryField(settings.fieldName)) {
            return;
        }

        for (copado__User_Story__c story : stories) {
            copado__User_Story__c oldStory = oldStories == null ? null : oldStories.get(story.Id);
            String oldValue = oldStory == null ? null : asValue(oldStory.get(settings.fieldName));
            String newValue = asValue(story.get(settings.fieldName));

            String title = buildTitle(
                story.copado__User_Story_Title__c, oldValue, newValue, settings.isSuffix, settings.allowTruncation
            );
            if (title != null && !title.equals(story.copado__User_Story_Title__c)) {
                story.copado__User_Story_Title__c = title;
            }
        }
    }

    /**
     * Returns the title with the tag for newValue at the configured end.
     * Tags for oldValue and newValue are first removed from both ends, so a changed key, a removed key and a
     * Prefix/Suffix mode change are all handled, and saving the same record again does not add the tag twice.
     * Returns the title unchanged when it is blank. When the new tag would not fit and truncation is off, returns
     * the title without any tag: the user's text is never cut, and a tag for an old key is not left behind.
     */
    @TestVisible
    private static String buildTitle(
        String title, String oldValue, String newValue, Boolean isSuffix, Boolean allowTruncation
    ) {
        if (String.isBlank(title)) {
            return title;
        }

        String base = removeTag(removeTag(title, oldValue), newValue);
        if (String.isBlank(base)) {
            // The title is only a tag; leave it rather than saving an empty title.
            return title;
        }
        if (String.isBlank(newValue)) {
            return base;
        }

        String tag = toTag(newValue);
        Integer available = MAX_TITLE_LENGTH - tag.length() - 1;
        if (base.length() > available) {
            if (!allowTruncation || available <= 0) {
                // The new tag does not fit. Keep the user's text as it is, but drop a stale tag for an
                // old key so the title never shows the wrong key.
                return base;
            }
            base = base.left(available).trim();
        }
        return isSuffix ? base + ' ' + tag : tag + ' ' + base;
    }

    /** Removes the tag for value from the start and the end of title. Returns title unchanged if no tag is found. */
    private static String removeTag(String title, String value) {
        if (String.isBlank(value)) {
            return title;
        }
        String tag = toTag(value);
        String result = title.trim();
        if (result.equals(tag)) {
            return '';
        }

        Boolean found = false;
        if (result.startsWith(tag + ' ')) {
            result = result.substring(tag.length()).trim();
            found = true;
        }
        if (result.endsWith(' ' + tag)) {
            result = result.substring(0, result.length() - tag.length()).trim();
            found = true;
        }
        return found ? result : title;
    }

    private static String toTag(String value) {
        return '[' + value.trim() + ']';
    }

    private static String asValue(Object fieldValue) {
        String value = fieldValue == null ? null : String.valueOf(fieldValue).trim();
        return String.isBlank(value) ? null : value;
    }

    private static Boolean isUserStoryField(String fieldName) {
        if (String.isBlank(fieldName)) {
            return false;
        }
        Map<String, Schema.SObjectField> fields = Schema.SObjectType.copado__User_Story__c.fields.getMap();
        Schema.SObjectField field = fields.get(fieldName.trim().toLowerCase());
        return field != null && field != copado__User_Story__c.copado__User_Story_Title__c;
    }

    @TestVisible
    private static Settings loadSettings(String name) {
        Toolbelt_Setting__mdt record = Toolbelt_Setting__mdt.getInstance(name);
        if (record == null) {
            return null;
        }
        return new Settings(
            record.User_Story_Title_Addition_Enabled__c,
            record.User_Story_Title_Addition_Field__c,
            record.User_Story_Title_Addition_Mode__c,
            record.User_Story_Title_Allow_Truncation__c
        );
    }

    @TestVisible
    private class Settings {
        public Boolean enabled;
        public String fieldName;
        public Boolean isSuffix;
        public Boolean allowTruncation;

        public Settings(Boolean enabled, String fieldName, String mode, Boolean allowTruncation) {
            this.enabled = enabled == true;
            this.fieldName = fieldName == null ? null : fieldName.trim();
            this.isSuffix = MODE_SUFFIX.equalsIgnoreCase(mode);
            this.allowTruncation = allowTruncation == true;
        }
    }
}

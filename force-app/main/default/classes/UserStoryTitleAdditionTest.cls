@IsTest
private class UserStoryTitleAdditionTest {

    // A Copado text field that exists in every org with Copado, so the tests do not depend on copadoccmint
    // or on the values of the org's Default record.
    private static final String ADDITION_FIELD = 'copado__Base_Branch__c';
    private static final String TITLE = 'Add new object';
    private static final String KEY = 'PROJ-1234';

    private static void configure(Boolean enabled, String fieldName, String mode, Boolean allowTruncation) {
        UserStoryTitleAddition.settingsOverride =
            new UserStoryTitleAddition.Settings(enabled, fieldName, mode, allowTruncation);
    }

    private static String build(String title, String oldValue, String newValue, Boolean isSuffix) {
        return UserStoryTitleAddition.buildTitle(title, oldValue, newValue, isSuffix, false);
    }

    // buildTitle

    @IsTest
    static void addsPrefix() {
        Assert.areEqual('[PROJ-1234] Add new object', build(TITLE, null, KEY, false));
    }

    @IsTest
    static void addsSuffix() {
        Assert.areEqual('Add new object [PROJ-1234]', build(TITLE, null, KEY, true));
    }

    @IsTest
    static void doesNotAddTagTwice() {
        Assert.areEqual('[PROJ-1234] Add new object', build('[PROJ-1234] Add new object', KEY, KEY, false));
        Assert.areEqual('Add new object [PROJ-1234]', build('Add new object [PROJ-1234]', KEY, KEY, true));
    }

    @IsTest
    static void replacesTagWhenKeyChanges() {
        Assert.areEqual(
            '[PROJ-5678] Add new object', build('[PROJ-1234] Add new object', KEY, 'PROJ-5678', false)
        );
        Assert.areEqual(
            'Add new object [PROJ-5678]', build('Add new object [PROJ-1234]', KEY, 'PROJ-5678', true)
        );
    }

    @IsTest
    static void removesTagWhenKeyIsCleared() {
        Assert.areEqual(TITLE, build('[PROJ-1234] Add new object', KEY, null, false));
        Assert.areEqual(TITLE, build('Add new object [PROJ-1234]', KEY, null, true));
    }

    @IsTest
    static void leavesTitleUntouchedWhenThereIsNoTagToRemove() {
        Assert.areEqual(' Add new object ', build(' Add new object ', null, null, false));
    }

    @IsTest
    static void movesTagWhenModeChanges() {
        Assert.areEqual('Add new object [PROJ-1234]', build('[PROJ-1234] Add new object', KEY, KEY, true));
        Assert.areEqual('[PROJ-1234] Add new object', build('Add new object [PROJ-1234]', KEY, KEY, false));
    }

    @IsTest
    static void leavesBlankOrTagOnlyTitleUnchanged() {
        Assert.isNull(build(null, null, KEY, false));
        Assert.areEqual('', build('', null, KEY, false));
        Assert.areEqual('[PROJ-1234]', build('[PROJ-1234]', KEY, KEY, false));
    }

    @IsTest
    static void truncatesEndOfTitleWhenAllowed() {
        String longTitle = 'a'.repeat(250);

        String result = UserStoryTitleAddition.buildTitle(longTitle, null, KEY, false, true);

        Assert.areEqual(255, result.length());
        Assert.isTrue(result.startsWith('[PROJ-1234] aaa'), result);

        result = UserStoryTitleAddition.buildTitle(longTitle, null, KEY, true, true);

        Assert.areEqual(255, result.length());
        Assert.isTrue(result.endsWith('aaa [PROJ-1234]'), result);
    }

    @IsTest
    static void leavesLongTitleUnchangedWhenTruncationIsOff() {
        String longTitle = 'a'.repeat(250);

        Assert.areEqual(longTitle, UserStoryTitleAddition.buildTitle(longTitle, null, KEY, false, false));
    }

    @IsTest
    static void removesStaleTagWhenLongerNewTagDoesNotFitAndTruncationIsOff() {
        // 10 + 1 + 244 = 255 fits; the new tag is one character longer, so it does not.
        String text = 'a'.repeat(244);

        Assert.areEqual(
            text, UserStoryTitleAddition.buildTitle('[PROJ-999] ' + text, 'PROJ-999', 'PROJ-1000', false, false)
        );
        Assert.areEqual(
            text, UserStoryTitleAddition.buildTitle(text + ' [PROJ-999]', 'PROJ-999', 'PROJ-1000', true, false)
        );
    }

    // apply

    @IsTest
    static void appliesOnInsertAndUpdate() {
        configure(true, ADDITION_FIELD, 'Prefix', false);
        Id storyId = fakeStoryId();
        copado__User_Story__c story = new copado__User_Story__c(
            Id = storyId, copado__User_Story_Title__c = TITLE, copado__Base_Branch__c = KEY
        );

        UserStoryTitleAddition.apply(new List<copado__User_Story__c>{ story }, null);

        Assert.areEqual('[PROJ-1234] Add new object', story.copado__User_Story_Title__c);

        copado__User_Story__c oldStory = story.clone(true);
        story.copado__Base_Branch__c = 'PROJ-5678';

        UserStoryTitleAddition.apply(
            new List<copado__User_Story__c>{ story }, new Map<Id, copado__User_Story__c>{ storyId => oldStory }
        );

        Assert.areEqual('[PROJ-5678] Add new object', story.copado__User_Story_Title__c);
    }

    @IsTest
    static void usesSuffixMode() {
        configure(true, ADDITION_FIELD, 'suffix', false);
        copado__User_Story__c story = newStory();

        UserStoryTitleAddition.apply(new List<copado__User_Story__c>{ story }, null);

        Assert.areEqual('Add new object [PROJ-1234]', story.copado__User_Story_Title__c);
    }

    @IsTest
    static void doesNothingWhenDisabled() {
        configure(false, ADDITION_FIELD, 'Prefix', false);
        copado__User_Story__c story = newStory();

        UserStoryTitleAddition.apply(new List<copado__User_Story__c>{ story }, null);

        Assert.areEqual(TITLE, story.copado__User_Story_Title__c);
    }

    @IsTest
    static void doesNothingWhenFieldDoesNotExist() {
        configure(true, 'Field_That_Does_Not_Exist__c', 'Prefix', false);
        copado__User_Story__c story = newStory();

        UserStoryTitleAddition.apply(new List<copado__User_Story__c>{ story }, null);

        Assert.areEqual(TITLE, story.copado__User_Story_Title__c);
    }

    @IsTest
    static void doesNothingWhenFieldIsTheTitle() {
        configure(true, 'copado__User_Story_Title__c', 'Prefix', false);
        copado__User_Story__c story = newStory();

        UserStoryTitleAddition.apply(new List<copado__User_Story__c>{ story }, null);

        Assert.areEqual(TITLE, story.copado__User_Story_Title__c);
    }

    @IsTest
    static void doesNothingWhenSettingRecordIsMissing() {
        UserStoryTitleAddition.settingName = 'Record_That_Does_Not_Exist';
        copado__User_Story__c story = newStory();

        UserStoryTitleAddition.apply(new List<copado__User_Story__c>{ story }, null);

        Assert.isNull(UserStoryTitleAddition.loadSettings('Record_That_Does_Not_Exist'));
        Assert.areEqual(TITLE, story.copado__User_Story_Title__c);
    }

    @IsTest
    static void loadsDefaultRecord() {
        UserStoryTitleAddition.Settings settings = UserStoryTitleAddition.loadSettings('Default');

        Assert.isNotNull(settings, 'The package ships a Toolbelt_Setting__mdt record named Default');
    }

    // Trigger

    @IsTest
    static void triggerAddsTagOnInsertAndReplacesItOnUpdate() {
        configure(true, ADDITION_FIELD, 'Prefix', false);
        copado__User_Story__c story = newStory();

        Test.startTest();
        insert story;
        story.copado__Base_Branch__c = 'PROJ-5678';
        update story;
        Test.stopTest();

        story = [SELECT copado__User_Story_Title__c FROM copado__User_Story__c WHERE Id = :story.Id];
        Assert.areEqual('[PROJ-5678] Add new object', story.copado__User_Story_Title__c);
    }

    private static copado__User_Story__c newStory() {
        return new copado__User_Story__c(copado__User_Story_Title__c = TITLE, copado__Base_Branch__c = KEY);
    }

    private static Id fakeStoryId() {
        return copado__User_Story__c.SObjectType.getDescribe().getKeyPrefix() + '000000000001';
    }
}

@isTest
private class TestLanguageCourseTrigger {

    @TestSetup
    static void setup() {
        Language_Course_Instructor__c instructor = new Language_Course_Instructor__c(
            Name = 'Test Instructor'
        );
        insert instructor;
    }

    private static Language_Course_Instructor__c getInstructor() {
        return [SELECT Id FROM Language_Course_Instructor__c LIMIT 1];
    }

    @isTest
    static void testInsert() {
        Language_Course__c course = new Language_Course__c(
            Name = 'Spanish 101',
            Course_Instructor__c = getInstructor().Id
        );

        Test.startTest();
        Database.SaveResult result = Database.insert(course, false);
        Test.stopTest();

        Assert.isTrue(result.isSuccess(), 'Insert should succeed: ' + result.getErrors());
        Assert.areEqual(1, [SELECT COUNT() FROM Language_Course__c], 'One course should exist');
    }

    @isTest
    static void testUpdate() {
        Language_Course__c course = new Language_Course__c(
            Name = 'French 101',
            Course_Instructor__c = getInstructor().Id
        );
        insert course;

        // Master-Detail is not reparentable, so only send the fields being changed
        Language_Course__c toUpdate = new Language_Course__c(Id = course.Id, Name = 'French 102');
        Test.startTest();
        Database.SaveResult result = Database.update(toUpdate, false);
        Test.stopTest();

        Assert.isTrue(result.isSuccess(), 'Update should succeed: ' + result.getErrors());
        Assert.areEqual('French 102', [SELECT Name FROM Language_Course__c WHERE Id = :course.Id].Name);
    }

    @isTest
    static void testDelete() {
        Language_Course__c course = new Language_Course__c(
            Name = 'German 101',
            Course_Instructor__c = getInstructor().Id
        );
        insert course;

        Test.startTest();
        Database.DeleteResult result = Database.delete(course, false);
        Test.stopTest();

        Assert.isTrue(result.isSuccess(), 'Delete should succeed: ' + result.getErrors());
        Assert.areEqual(0, [SELECT COUNT() FROM Language_Course__c], 'No courses should remain');
    }

    @isTest
    static void testBulkInsert() {
        Id instructorId = getInstructor().Id;
        List<Language_Course__c> courses = new List<Language_Course__c>();
        for (Integer i = 0; i < 200; i++) {
            courses.add(new Language_Course__c(
                Name = 'Course ' + i,
                Course_Instructor__c = instructorId
            ));
        }

        Test.startTest();
        insert courses;
        Test.stopTest();

        Assert.areEqual(200, [SELECT COUNT() FROM Language_Course__c], 'All 200 courses should be inserted');
    }
}

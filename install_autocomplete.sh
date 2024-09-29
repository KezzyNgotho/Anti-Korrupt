#!/bin/bash

# Install autocomplete for ./cli
complete -W "listCourses addAcls addQuestion changeApiKey changeOwner check_course_has_memory_vectors_entry createCourse getCourseQuestions getOwner getProfile getRandomCourseQuestions enrollCourse generateRandomNumber getCourseResources createResource getRunMessage getRunQuestions getRunStatus getRunsInQueue getUserEnrolledCourse removeAcls removeQuestion removeResource sendMessage setAssistantId setRunProcess set_icrc1_token_canister updateCourse generateQuestionsForCourse" ./cli
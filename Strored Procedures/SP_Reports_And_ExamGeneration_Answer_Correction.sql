use ITIExaminationSystem

-- Exam_Generation
create proc ExamGeneration
    @CrsName VARCHAR(50),
    @NumOf_MCQ INT,
    @Numof_TF INT,
    @ExamName VARCHAR(50)  
AS
BEGIN TRY 
    BEGIN
        DECLARE @Crs_id INT;
        SET @Crs_id = (SELECT C_id FROM Course WHERE C_Name = @CrsName);

        
        IF @Crs_id IS NULL 
        BEGIN
            SELECT 'This Course Does Not Exist.' AS ErrorMessage;
            RETURN;
        END

         --validate total no of questions
       if (@NumOf_MCQ + @Numof_TF) > 10 OR (@NumOf_MCQ + @Numof_TF) < 10
        begin
            select 'The total number of questions (MCQ + T/F) must equql 10.' AS ErrorMessage;
            return;
        end

        
        if (SELECT COUNT(*) FROM Question WHERE C_Id = @Crs_id AND type = 'MCQ') < @NumOf_MCQ
      begin
            select 'Not enough MCQ questions available for this course.' as ErrorMessage;
            return;
        end

        if (SELECT COUNT(*) FROM Question WHERE C_Id = @Crs_id AND type = 'T/F') < @Numof_TF
        begin
            select 'Not enough T/F questions available for this course.' AS ErrorMessage;
           return;
        END

        
       declare @ExamId INT;
       select @ExamId = ISNULL(MAX(Ex_Id), 0) + 100 FROM Exam;

        insert into Exam (Ex_id, Ex_name, Ex_date, C_id, total_score)
       values (@ExamId, @ExamName, GETDATE(), @Crs_id, 100);

       
        insert into  Exam_Has_Quesstion (Ex_id, Q_id)
        SELECT TOP (@NumOf_MCQ) @ExamId, Q_id
        FROM Question
        WHERE C_Id = @Crs_id AND type = 'MCQ'
        ORDER BY NEWID();

        INSERT INTO Exam_Has_Quesstion (Ex_id, Q_id)
        SELECT TOP (@Numof_TF) @ExamId, Q_id
        FROM Question
        WHERE C_Id = @Crs_id AND type = 'T/F';

        SELECT 'Exam created successfully!' AS SuccessMessage;
    END
END TRY
BEGIN CATCH
    SELECT 'ERROR! Invalid Data.' AS ErrorMessage;
END CATCH;

ExamGeneration 'Data Science',5,5,'Data Science Exam'
ExamGeneration 'Networking Fundamentals',6,4,'Networking Fundamentals Exam'
ExamGeneration 'Cybersecurity Essentials',3,7,'Cybersecurity Essentials Exam'
ExamGeneration 'Object-Oriented Programming',7,3,'Object-Oriented Programming Exam'
--------------
--------------
----Exam Answers
alter PROC Exam_Answers
    @ex_id INT, 
    @name VARCHAR(50),
    @A1 VARCHAR(20), @A2 VARCHAR(20), @A3 VARCHAR(20), @A4 VARCHAR(20),
    @A5 VARCHAR(20), @A6 VARCHAR(20), @A7 VARCHAR(20), @A8 VARCHAR(20),
    @A9 VARCHAR(20), @A10 VARCHAR(20)
AS
BEGIN
    DECLARE @StuAns TABLE (ex_id INT, Answer VARCHAR(20));
    INSERT INTO @StuAns(ex_id, Answer)
    VALUES
        (@ex_id, @A1), (@ex_id, @A2), (@ex_id, @A3), (@ex_id, @A4), (@ex_id, @A5),
        (@ex_id, @A6), (@ex_id, @A7), (@ex_id, @A8), (@ex_id, @A9), (@ex_id, @A10);

    BEGIN TRY
        DECLARE @st_id INT;
        SET @st_id = (
            SELECT st_id 
            FROM Student 
            WHERE 
                fname = (SELECT PARSENAME(REPLACE(@name, ' ', '.'), 2)) AND
                lname = (SELECT PARSENAME(REPLACE(@name, ' ', '.'), 1))
        );

        IF NOT EXISTS (SELECT ex_id FROM Exam WHERE ex_id = @ex_id)
        BEGIN
            SELECT 'Exam ID is not valid';
            RETURN;
        END;

        IF @st_id IS NULL
        BEGIN
            SELECT 'Your name does not exist';
            RETURN;
        END;

        IF NOT EXISTS (SELECT Q_id FROM Exam_has_Quesstion WHERE ex_id = @ex_id)
        BEGIN
            SELECT 'No questions found for the given Exam ID';
            RETURN;
        END;

        DECLARE c1 CURSOR LOCAL FAST_FORWARD FOR 
            SELECT Q_id 
            FROM Exam_has_Quesstion 
            WHERE ex_id = @ex_id;

        DECLARE c2 CURSOR LOCAL FAST_FORWARD FOR 
            SELECT Answer 
            FROM @StuAns;

        DECLARE @Q_id INT;
        DECLARE @Answer VARCHAR(20);

        OPEN c1;
        OPEN c2;

        FETCH NEXT FROM c1 INTO @Q_id;
        FETCH NEXT FROM c2 INTO @Answer;

        WHILE @@FETCH_STATUS = 0
        BEGIN
            INSERT INTO Student_Exam_Question (st_id, ex_id, Q_id, Answer)
            VALUES (@st_id, @ex_id, @Q_id, @Answer);

            FETCH NEXT FROM c1 INTO @Q_id
            FETCH NEXT FROM c2 INTO @Answer
        END

        CLOSE c1;
        DEALLOCATE c1;

        CLOSE c2;
        DEALLOCATE c2;

    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END;
 Exam_Answers 300,'Mazen Ali','a','a','a','a','a','T','T','F','T','F'
 Exam_Answers 400,'Mazen Ali','c','c','d','d','c','a','T','T','T','T'

-------------------
-------------------
---Exam Correction

CREATE PROC Correct_Exam
    @ex_id INT,
    @student_name NVARCHAR(50)
AS
BEGIN
    BEGIN TRY
        DECLARE @fname NVARCHAR(20) = PARSENAME(REPLACE(@student_name, ' ', '.'), 2);
        DECLARE @lname NVARCHAR(20) = PARSENAME(REPLACE(@student_name, ' ', '.'), 1);

       
        DECLARE @st_id INT;
        SELECT @st_id = st_id
        FROM Student
        WHERE fname = @fname AND lname = @lname;

        IF @st_id IS NULL
        BEGIN
            SELECT 'Student name not found' AS ErrorMessage;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Exam WHERE ex_id = @ex_id)
        BEGIN
            SELECT 'Exam ID is not valid' AS ErrorMessage;
            RETURN;
        END

        IF NOT EXISTS (SELECT 1 FROM Student_Exam_Question WHERE st_id = @st_id AND ex_id = @ex_id)
        BEGIN
            SELECT 'No answers found for the student in the given exam' AS ErrorMessage;
            RETURN;
        END

        UPDATE SEQ
        SET SEQ.grade = CASE 
                            WHEN SEQ.Answer = Q.model_answer THEN (SELECT total_score FROM Exam WHERE ex_id=@ex_id)*.1
                            ELSE 0
                        END
        FROM Student_Exam_Question SEQ
        INNER JOIN Question Q ON SEQ.Q_id = Q.Q_id
        WHERE SEQ.st_id = @st_id AND SEQ.ex_id = @ex_id;

		declare @percentage int
		SET @percentage = ((SELECT SUM(grade) FROM Student_Exam_Question WHERE ex_id=@ex_id AND st_id=@st_id GROUP BY ex_id,st_id)*(SELECT total_score FROM Exam WHERE ex_id=@ex_id ))/100
        SELECT 'Exam correction completed successfully' AS SuccessMessage, CONCAT(@percentage,'%') As Result ;
    END TRY
    BEGIN CATCH
        SELECT ERROR_MESSAGE() AS ErrorMessage;
    END CATCH
END;


Correct_Exam 300,'Mazen Ali'
Correct_Exam 400,'Mazen Ali'

-- Report that returns the students information according to Department No parameter.
create proc GetStudentsByDeptNum @dnum int 
as 
	select * 
	from Student
	where T_id_fk=@dnum

--Report that takes the student ID and returns the grades of the student in all courses
create proc GetGradesInAllCouresBystdId @st_id int
as
	select c.C_Name , SUM(sq.grade)'grade' --/e.total_score *100 as 
	from Student_Exam_Question sq,Exam e,Course c
	where sq.ex_id=e.ex_id and e.c_id=c.C_Id and sq.st_id=@st_id
	group by c.C_Name

--Report that takes the instructor ID and returns the name of the courses that he teaches and the number of student per course.
create proc GetCourseAndNumOfStudByInstructorId @ins_id int
as
	select c.C_Name , count(s.st_id) as 'Number of Students'
	from Instructor_Teach_Cource itc
	inner join Course c 
	on c.C_Id =itc.C_id_fk and itc.ins_id_fk =@ins_id
	inner join CourseHasTrack ct
	on c.C_Id=ct.C_Id 
	inner join track t
	on t.T_id=ct.Track_Id
	inner join Student s
	on t.T_id=s.T_id_fk
	group by c.C_Name

--Report that takes course ID and returns its topics  
create proc GetTopicByCourseId @course_id int
as 
	select t.name
	from Topic t
	where t.C_id_fk=@course_id


--Report that takes exam number and returns the Questions in it and chocies [freeform report]
create proc GetQuestionsByExamNum @ExamNum int
as
	select q.title,c.choice,c.textOfChoice,
	from Exam_has_Quesstion ex inner join Question q
	on q.Q_id=ex.Q_id and ex.ex_id=@ExamNum
	inner join Question_choice c
	on c.Q_id=q.Q_id

--Report that takes exam number and the student ID then returns the Questions in this exam with the student answers. 
create proc GetExam_Questions_Model_stud_Answer @ExamNum int ,@StudId int 
as
	select distinct(q.title),q.model_answer,sq.Answer
	from Exam_has_Quesstion exq inner join Question q
	on q.Q_id=exq.Q_id and exq.ex_id=@ExamNum
	inner join Question_choice c
	on c.Q_id=q.Q_id 
	inner join Student_Exam_Question sq
	on sq.Q_id=q.Q_id and sq.st_id=@StudId and sq.ex_id=@ExamNum






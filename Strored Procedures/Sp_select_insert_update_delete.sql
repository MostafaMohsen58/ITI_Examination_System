-- Instructor table --
-- Select-- (select data by passing instructor id)
create proc GetInstData @id int = Null
as
begin
   if @id is Null
   select * from Instructor
   else
   begin
   if @id is Not Null and @id in (select Ins_Id from Instructor)
      begin
        select * from Instructor where Ins_Id = @id
	   end
	else
		begin
		  select'This Id Dose Not Exist.'
		end
	end
end
--Insert--
create proc sp_InsertIntoInst
@name varchar(20), 
@salary int
as 
begin
		   Insert into Instructor (Ins_Name,Ins_salary)
		   values(@name,@salary)
 end

--Delete-- (delete instructor data but no delete if instructor is in track or teaching course)
create proc DeleteInst @id int
as
begin
    if not exists (select Ins_Id from Instructor where Ins_Id = @id)
    begin
        select 'Instructor not found'
    end
    if exists (select T_Id from Track where T_Id in 
	(select T_Id from InstWorksInTrack where Ins_Id = @id))
    begin
        select 'Cannot delete. This instructor is associated with a track.'
    end
    if exists (select C_Id from Course where C_Id in 
	(select C_Id from Instructor_Teach_Cource where ins_id_fk = @id))
    begin
        Select 'Cannot delete. This instructor is teaching a course.'
    end
    delete from Instructor where Ins_Id = @id
    select 'Instructor deleted successfully.'
end
--update-- (update instructor name,salary and email)
create proc UpdateInst 
@id int, 
@name varchar(20) = NULL , 
@salary int = NULL ,
@email varchar(50) = NULL
as 
   begin try
        if not exists (select Ins_Id from Instructor where Ins_id = @id) 
		begin
	       select 'Instructor Dose Not Exist.'
		 end
	   else 
	     begin
			 update Instructor 
			  set
			   Ins_Name = COALESCE(@name, Ins_Name),
               Ins_Salary = COALESCE(@salary, Ins_Salary),
               Ins_Email = COALESCE(@email, Ins_Email)
			 where Ins_Id = @id
	      end
   end try
   begin catch
        select 'Invalid Data.'
   end catch
 ---------------
--InstWorksInTrack
-- Select--(based on Instructor id)
create proc GetInstTrack  @id int = NULL
as
begin
   if @id is Null
   select * from InstWorksInTrack
   else
   begin
   if @id is Not Null and @id in (select Ins_Id from InstWorksInTrack)
      begin
        select * from InstWorksInTrack where Ins_Id = @id
	   end
	else
		begin
		  select'This Id Dose Not Exist'
		end
	end
end
--Insert--
create proc InsertInto_InsWorksInTrack
@insId int,
@trackId int,
@hiringdate date
as
begin
   begin try
   begin
   if not exists (select T_Id from Track where T_Id = @trackid)
   select'Sorry This Track Dose Not Exist.'
   end
   begin
   if not exists (select Ins_Id from Instructor where Ins_Id = @insId)
   select'Sorry This Instructor Dose Not Exist.'
   end
   begin
   if exists (select Ins_Id from InstWorksInTrack where Ins_Id = @insId and Track_Id = @trackid)
   select'This Record Alraedy Exists.'
   end
   insert into InstWorksInTrack (Ins_ID , Track_id , hiringdate)
   values (@insId,@trackId,@hiringdate)
   end try

   begin catch
   select 'Invalid data'
   end catch
end
--update--
create procedure updateInstWorksInTrack 
    @oldtrackid int,
    @oldinstid int,
    @newtrackid int = null,
    @newinstid int = null,
    @hiringdate date = null
as
begin
    begin try
        if not exists (select Ins_Id 
                       from InstWorksInTrack 
                       where Ins_Id = @oldinstid and Track_Id = @oldtrackid)
        begin
            select 'error: the record does not exist in instworksintrack.'
        end
        else
        begin
            if @newtrackid is not null and not exists (select T_id from track where T_id = @newtrackid)
            begin
                select 'error: this track does not exist.'
            end
            else
            begin
                if @newinstid is not null and not exists (select Ins_Id from Instructor where Ins_Id = @newinstid)
                begin
                    select 'error: this instructor does not exist.'
                end
                else
                begin
                    if @newtrackid is not null and @newinstid is not null and exists
					(select Ins_Id 
                      from InstWorksInTrack 
                       where Track_Id = @newtrackid and Ins_Id = @newinstid)
                    begin
                        select 'error: a record with the new track id and instructor id already exists.'
                    end
                    else
                    begin
                        update InstWorksInTrack
                        set 
                            Track_Id = coalesce(@newtrackid, Track_Id),
                            Ins_Id = coalesce(@newinstid, Ins_Id),
                            HiringDate = coalesce(@hiringdate, HiringDate)
                        where 
                            Track_Id = @oldtrackid and Ins_Id = @oldinstid;

                        select 'record updated successfully.'
                    end
                end
            end
        end
    end try
    begin catch
        select 'error: an unexpected error occurred.'
    end catch
end
--delete--
create proc DeleteInstWorksInTrack 
@instid int,
@trackid int
as
  begin  
   if not exists (select ins_id from InstWorksInTrack where ins_id = @instid and track_id =@trackid)
   select 'Sorry this record dose not exist.'
  end 
  delete from InstWorksInTrack where ins_id = @instid and track_id =@trackid
----------
--course--
--Select--
create proc GetCourseData @id int = Null
as
begin
   if @id is Null
   select * from Course
   else
   begin
   if @id is Not Null and @id in (select C_Id from Course)
      begin
        select * from Course where C_Id = @id
	   end
	else
		begin
		  select'This Id Dose Not Exist'
		end
	end
end
--Insert--
create proc InsertIntoCourse
@name varchar(20), 
@duration int,
@desc varchar(50)
as 
begin
      begin
		   Insert into Course  (C_Name,C_duration,C_Description)
		   values(@name,@duration,@desc)
      end
 end
 --Delete--
 create proc DeleteCourseData @id int
 as
   if not exists (select C_Id from Course where C_Id = @id)
   select 'This Id Dose Not Exists.'
   else
   delete from Course where C_Id = @id

 
--Update-- 
create procedure updateCourse 
 @id int,
 @name varchar(20) = null,
 @duration int = null
as
begin
    begin try
        if exists(select c_id from course where c_id = @id)
        begin
            update course
            set 
                c_name = coalesce(@name, c_name),
                C_Duration = coalesce(@duration, C_Duration)
            where C_id = @id

            select 'Course updated successfully.' 
        end
        else
        begin
            select 'Error: Course does not exist.'
        end
    end try
    begin catch
     select'Error occurs'
    end catch
end
-------------
--CourseHasTrack
--select
create proc GetCourseTrack @id int = Null
as
begin
   if @id is Null
   select * from CourseHasTrack
   else
   begin
   if @id is Not Null and @id in (select C_Id from CourseHasTrack)
      begin
        select * from Course where C_Id = @id
	   end
	else
		begin
		  select'This Id Dose Not Exist'
		end
	end
end
-- insert
create proc InsertIntoCourseHasTrack 
@CourseId int,
@TrackId int
as
   if exists (select C_id from CourseHasTrack where c_id=@CourseId and Track_Id=@TrackId)
   begin
   select'This Record Already Exists.'
   end
   else
   begin
   if exists (select C_id from Course where C_id = @CourseId)
      begin
      if exists (select T_id from track where T_id = @TrackId)
			begin
			  insert into CourseHasTrack (C_id,Track_Id)
			  values (@courseId,@TrackId)
			end
        else
		select'This Id Dose Not Match Either Course Or Track.'
      end   
	  else
	  select'This Id Dose Not Match Either Course Or Track.'
   end
   
-- Update
CREATE PROC UpdateCourseHasTrack
    @oldCrsid INT,
    @oldTrackid INT,
    @newCrsid INT = NULL,
    @newTrackid INT = NULL
AS
BEGIN
    IF NOT EXISTS (SELECT C_id FROM CourseHasTrack WHERE C_Id = @oldCrsid AND Track_Id = @oldTrackid)
    BEGIN
        SELECT 'ERROR! This Record Does Not Exist.';
        RETURN;
    END

    IF @newCrsid IS NOT NULL 
    BEGIN
        IF NOT EXISTS (SELECT C_Id FROM Course WHERE C_Id = @newCrsid)
        BEGIN
            SELECT 'ERROR! This Course Does Not Exist.';
            RETURN;
        END
    END

    IF @newTrackid IS NOT NULL 
    BEGIN
        IF NOT EXISTS (SELECT T_Id FROM Track WHERE T_Id = @newTrackid)
        BEGIN
            SELECT 'ERROR! This Track Does Not Exist.';
            RETURN;
        END
    END

    IF @newCrsid IS NOT NULL AND @newTrackid IS NOT NULL 
    BEGIN
        IF EXISTS (SELECT C_Id FROM CourseHasTrack WHERE C_Id = @newCrsid AND Track_Id = @newTrackid)
        BEGIN
            SELECT 'ERROR! This Record Already Exists.';
            RETURN;
        END
    END

    UPDATE CourseHasTrack
    SET
        C_Id = COALESCE(@newCrsid, C_Id),
        Track_Id = COALESCE(@newTrackid, Track_Id)
    WHERE 
        C_Id = @oldCrsid AND Track_Id = @oldTrackid;

    SELECT 'Record Updated Successfully.';
END


-- Delete 
create proc DeleteCourseHasTrack 
@crsid int,
@trackid int

as
   if not exists (select * from CourseHasTrack where C_Id = @crsid and Track_Id = @trackid)
   select 'This Id Dose Not Exists.'
   else
   delete from CourseHasTrack where C_Id = @crsid and Track_Id = @trackid

--select all from topic
      CREATE PROCEDURE sp_Topic_SelectAll
      AS
      BEGIN
      SELECT *
      FROM Topic;
      END
--select all from topic or select by it is id
             CREATE PROCEDURE sp_Topic_SelectByPK  @C_id_fk INT 
               AS
			   if @C_id_fk in (select C_id_fk from Topic)
			       begin
				   select *
				   from Topic 
				   where  C_id_fk = @C_id_fk
				   end 
				else 
				select('This Topic is Not Exist') 
    
 --------
--insert into topic
      CREATE PROCEDURE sp_Topic_Insert @C_id_fk INT = null ,@name VARCHAR(20) = null
      AS
	  IF @name IS NULL OR LEN(@name) = 0
        BEGIN
            select('Topic name cannot be NULL or empty.')
        END
	  else  if @C_id_fk in (select c.C_Id from Course c  )
          BEGIN
               INSERT INTO Topic (name, C_id_fk)
               VALUES (@name, @C_id_fk);
			   select ('Inserted completed successfully.')
          END
	  else
	      BEGIN
              SELECT 'This id of Course is not exist or this topic is already exist'
          END
--update topic
      CREATE PROCEDURE sp_Topic_Update
	      @name varchar(20) = null,
          @C_id_fk INT = null,
          @new_name VARCHAR(20) = null,
          @new_C_id_fk INT = null
      AS
     begin
	     begin try
	      if (@name in (select t.name from Topic t) and @C_id_fk in (select t.C_id_fk from Topic t))
		       begin
	           update Topic 
	           set 
	     	   name=COALESCE(@new_name,name),
	     	   C_id_fk=COALESCE(@new_C_id_fk,C_id_fk)
	     	   where C_id_fk = @C_id_fk and name=@name
	           select 'Update completed successfully.'
			   end
		  else
		    select 'this id is not exist'
	     end try
	     Begin catch
	     select 'Data does not match';
	     end catch
     end
--delete from topic
     CREATE PROCEDURE sp_Topic_Delete @name VARCHAR(20) = null,  @C_id_fk INT = null
	 
      AS
      BEGIN
	      if (@name in (select t.name from Topic t) and @C_id_fk in (select t.C_id_fk from Topic t))
		  begin
              DELETE FROM Topic
              WHERE name = @name AND C_id_fk = @C_id_fk;
			  select 'Delete completed successfully.'
		  end
		  else 
		   	select('This Topic is Not Exist') 
      END

	  
--InstructorTeachCource
--select all from InstructorTeachCource
      CREATE PROCEDURE usp_InstructorTeachCource_SelectAll
      AS
      BEGIN
          SELECT *
          FROM Instructor_Teach_Cource;
      END
--select from InstructorTeachCource depend on id
      CREATE PROCEDURE sp_InstructorTeachCource_SelectByPK @ins_id_fk INT
      AS
      BEGIN
	      if( @ins_id_fk in (select Ins_Id from Instructor) )
          begin
			  SELECT ins_id_fk, C_id_fk
			  FROM Instructor_Teach_Cource
			  WHERE ins_id_fk = @ins_id_fk
		  end 
		  else 
		  	select('This instructor does not teach course.') 
      END
	
--insert into InstructorTeachCource 
      create PROCEDURE sp_InstructorTeachCource_Insert @ins_id_fk INT=null, @C_id_fk INT=null
      AS
      BEGIN
		  if exists (select 1 from Instructor_Teach_Cource where @ins_id_fk=@ins_id_fk and C_id_fk=@C_id_fk)
		  select'This Record already exist.'
	      else if (@ins_id_fk in (select i.Ins_Id from Instructor i )
		  and @C_id_fk in (select c.C_Id from course c ))
          begin
		  INSERT INTO Instructor_Teach_Cource (ins_id_fk, C_id_fk)
          VALUES (@ins_id_fk, @C_id_fk);
		  select ('Inserted completed successfully.')
		  end 
		  else
		  select ('Data does not match')
      END
--update InstructorTeachCource
      CREATE PROCEDURE usp_InstructorTeachCource_Update
          @ins_id_fk INT = null,
          @C_id_fk INT = null,
          @new_ins_id_fk INT = null,
          @new_C_id_fk INT = null
      AS
      BEGIN
	      if not exists(select ins_id from instructor where ins_id= @new_ins_id_fk)
		  select'This Instructor Does Not exist.'
		  else if not exists(select C_id from Course where C_id= @new_c_id_fk)
		  select'This Instructor Does Not exist.'
	      else if (@ins_id_fk in (select i.ins_id_fk from Instructor_Teach_Cource i) 
		  and @C_id_fk in (select i.C_id_fk from Instructor_Teach_Cource i))
          begin
		  UPDATE Instructor_Teach_Cource
          SET 
		  ins_id_fk = COALESCE (@new_ins_id_fk,ins_id_fk),
          C_id_fk = COALESCE (@new_C_id_fk,C_id_fk)
          WHERE ins_id_fk = @ins_id_fk AND C_id_fk = @C_id_fk;
		  select ('Updated completed successfully.')
		  end
		  else
		  select ('Data does not match');
      END
--delete from InstructorTeachCource
      CREATE PROCEDURE sp_InstructorTeachCource_Delete
          @ins_id_fk INT ,
          @C_id_fk INT
		 
      AS
      BEGIN
	      if (@ins_id_fk in (select i.ins_id_fk from Instructor_Teach_Cource i) 
		  and @C_id_fk in (select i.C_id_fk from Instructor_Teach_Cource i))
		       begin
               DELETE FROM Instructor_Teach_Cource 
               WHERE ins_id_fk = @ins_id_fk AND C_id_fk = @C_id_fk;
		       select 'Delete completed successfully.'
		  end
		  else 
		   	select('This Table is Not Exist') 
		  
      END
---Student
--select all from Student
      CREATE PROCEDURE usp_Student_SelectAll
      AS
      BEGIN
          SELECT *
          FROM Student;
      END
--select from Student depend on id
      CREATE PROCEDURE usp_Student_SelectByPK @st_id INT

      AS
      BEGIN
	      IF EXISTS (SELECT 1 FROM Student WHERE st_id = @st_id)
          BEGIN
              SELECT *
              FROM Student
              WHERE st_id = @st_id;
          END
		  select 'This Student Is Not Exist'
      END
--insert into Student
      create PROCEDURE usp_Student_Insert
          @fname VARCHAR(20) = null,
          @lname VARCHAR(20) = null,
          @gender VARCHAR(1) = null,
          @Email VARCHAR(20) = null ,
          @BOD DATE = null,
          @T_id_fk INT = null 
      AS
      BEGIN
	  begin try
	  if not exists(select T_id from Track where t_id =@T_id_fk)
	  select'This track does not exist.'
	  else
	  begin
          INSERT INTO Student (fname, lname, gender, Email, BOD, T_id_fk)
          VALUES (@fname, @lname, @gender, @Email, @BOD, @T_id_fk);
		  select ('Inserted completed successfully.')
	  end
	  End try
	  Begin catch
	     select 'Data does not match';
	  end catch
      END
--update Student
      CREATE PROCEDURE usp_Student_Update
          @st_id INT = null ,
          @fname VARCHAR(20) = null,
          @lname VARCHAR(20) = null,
          @gender VARCHAR(1) = null,
          @Email VARCHAR(20) = null,
          @BOD DATE = null,
          @T_id_fk INT = null
      AS
      BEGIN
	       if not exists(select T_id from Track where t_id =@T_id_fk)
	       select'This track does not exist.'
	      else if exists (select s.st_id from Student s where s.st_id = @st_id)
		  begin
          UPDATE Student
          SET fname = COALESCE(@fname,fname),
              lname = COALESCE(@lname,lname),
              gender =COALESCE(@gender,gender),
              Email = COALESCE (@Email,Email),
              BOD =COALESCE(@BOD,BOD),
              T_id_fk =Coalesce(@T_id_fk,T_id_fk)
          WHERE st_id = @st_id;
		   select 'Update completed successfully.'
		  end
		  else 
		  select'This record does not exist to be updated.'
      END
--delete from Student
      CREATE PROCEDURE usp_Student_Delete
          @st_id INT = null
      AS
      BEGIN
	      if exists (select s.st_id from Student s)
		  begin 
          DELETE FROM Student
          WHERE st_id = @st_id;
		  select 'Delete completed successfully.'
		  end 
		  else 
		  select 'This Student Is Not Exist'
      END
      
--------Branch
--select all from Branch
      CREATE PROCEDURE usp_Branch_SelectAll
      AS
      BEGIN
          SELECT *
          FROM Branch;
      END
--select from Branch depend on id
      CREATE PROCEDURE usp_Branch_SelectById
          @B_id INT = null
      AS
      BEGIN
	  if exists (select b.B_id from branch b WHERE B_id = @B_id)
	  begin
          SELECT *
          FROM Branch
          WHERE B_id = @B_id;
	  end
	  else 
	  select 'This Branch is Not Exist'
      END
--insert into Branch
-----------
      CREATE PROCEDURE usp_Branch_Insert
          @B_name VARCHAR(20) = null,
          @Location VARCHAR(50) = null
		  
      AS
      BEGIN
	  begin try
          INSERT INTO Branch (B_name, Location)
          VALUES (@B_name, @Location);
		  select ('Inserted completed successfully.')
	  end try
	  begin catch
	  select ('Data does not match');
	  end catch
      END
--update Branch
      CREATE PROCEDURE usp_Branch_Update
          @B_id INT = null,
          @B_name VARCHAR(20) = null,
          @Location VARCHAR(50) =  null
      AS
      BEGIN
	      if exists (select b.B_id from branch b WHERE B_id = @B_id)
		  begin
          UPDATE Branch
          SET
		  B_name = coalesce (@B_name,B_name),
          Location =coalesce (@Location,Location)
          WHERE B_id = @B_id;
          select 'Update completed successfully.'
		  end
		  else
		  select 'This id is not exist'
      END
--delete from Branch
      CREATE PROCEDURE usp_Branch_Delete
          @B_id INT =null
      AS
      BEGIN
	  if exists (select b.B_id from branch b WHERE B_id = @B_id)
          begin
		  DELETE FROM Branch
          WHERE B_id = @B_id;
		  select 'Delete completed successfully.'
          END
	      else 
	      select 'This Branch is Not Exist'
      END
------Branch_Phone
--select all from Branch_Phone
     CREATE PROCEDURE usp_BranchPhone_SelectAll
     AS
     BEGIN
         SELECT *
         FROM Branch_Phone;
     END
--select from Branch_Phone depend on id
     CREATE PROCEDURE usp_BranchPhone_SelectByBranch
         @B_id_fk INT = null
     AS
     BEGIN
	     if exists (select b.B_id_fk from Branch_Phone b WHERE B_id_fk = @B_id_fk)
		 begin
         SELECT *
         FROM Branch_Phone
         WHERE B_id_fk = @B_id_fk;
		 end 
		 else 
	  select 'This Branch is Not Exist'
     END
--insert into Branch_Phone
     CREATE PROCEDURE usp_BranchPhone_Insert
         @B_id_fk INT = null,
         @Phone VARCHAR(11) = null
     AS
     BEGIN
	      begin try
		  if exists (select B_id from branch where B_id = @B_id_fk)
		  begin
          INSERT INTO Branch_Phone (B_id_fk, Phone)
          VALUES (@B_id_fk, @Phone);
		  select ('Inserted completed successfully.')
		  end
		  else
		  select'This branch Does Not Exist.'
	      end try
	      begin catch
	      select ('Data does not match');
	      end catch
     END
--delete from Branch_Phone
     CREATE PROCEDURE usp_BranchPhone_Delete
         @B_id_fk INT = null,
         @Phone VARCHAR(11) = null
     AS
     BEGIN
	 if (@B_id_fk in (select b.B_id_fk from Branch_Phone b ) 
	     and @Phone in (select b.Phone from Branch_Phone b))
          begin
          DELETE FROM Branch_Phone
          WHERE B_id_fk = @B_id_fk AND Phone = @Phone
          END
	      else 
	      select 'This Branch is Not Exist.'
     END
----Track
--select all from Track
    CREATE PROCEDURE usp_Track_SelectAll
    AS
    BEGIN
        SELECT *
        FROM Track
    END
--select from Track depend on id
    CREATE PROCEDURE usp_Track_SelectById
        @T_id INT = null
    AS
    BEGIN
       if exists (select t.T_id from track t)
	    begin
        SELECT *
        FROM Track
        WHERE T_id = @T_id
	    end
	  else 
	  select 'This Track is Not Exist'
      END
--insert into Track
    CREATE PROCEDURE usp_Track_Insert
        @T_name VARCHAR(20) = null,
        @description VARCHAR(50) = null
      AS
      BEGIN
	  begin try
          INSERT INTO Track (T_name, description)
          VALUES (@T_name, @description);
		  select ('Inserted completed successfully.')
	  end try
	  begin catch
	  select ('Data does not match');
	  end catch
      END

--update Track
    CREATE PROCEDURE usp_Track_Update
        @T_id INT =null,
        @T_name VARCHAR(20) = null,
        @description VARCHAR(50) = null
      AS
      BEGIN
	      if exists (select t.T_id from track t where T_id = @T_id )
		  begin
          UPDATE Track
           SET 
	  	   T_name = coalesce (@T_name,t_name),
           description =coalesce (@description,description)
           WHERE T_id = @T_id;
		  end
		  else
		  select 'This id is not exist'
      END
--delete from Track
    create PROCEDURE usp_Track_Delete
        @T_id INT =null
    AS
    BEGIN
	    if exists (select t.T_id from track t where T_id = @T_id )
	    begin
        DELETE FROM Track
        WHERE T_id = @T_id;
	 END
	      else 
	      select 'This Track is Not Exist'
    END
----------Track_Branch
--select all from Track_Branch
   CREATE PROCEDURE usp_TrackBranch_SelectAll
   AS
   BEGIN
       SELECT *
       FROM Track_Branch;
   END
--select from Track_Branch depend on id
   CREATE PROCEDURE usp_TrackBranch_SelectByPK
       @B_id_fk INT = null,
       @T_id_fk INT = null

      AS
      BEGIN
	  if (@B_id_fk in (select t.B_id_fk from track_branch t) 
	      and @T_id_fk in (select t.T_id_fk from track_branch t))
	  begin
          SELECT B_id_fk, T_id_fk
          FROM Track_Branch
          WHERE B_id_fk = @B_id_fk AND T_id_fk = @T_id_fk;
	  end
	  else 
	  select 'This Track is Not Exist in This Branch'
      END
--insert into Track_Branch
   create PROCEDURE usp_TrackBranch_Insert
       @B_id_fk INT = null,
       @T_id_fk INT = null
      AS
      BEGIN
	  begin try
		  if not exists (select T_id from track where t_id =@T_id_fk)
		  select'This Track Does Not exist.'
		  else if not exists (select B_id from branch where B_id =@B_id_fk)
		  select'This Branch Does Not exist.'
		  else if exists (select 1 from track_branch where T_id_fk =@T_id_fk and B_id_fk =@B_id_fk)
		  select'This Record Already Exist.'
		  else
		  begin
		   INSERT INTO Track_Branch (B_id_fk, T_id_fk)
		   VALUES (@B_id_fk, @T_id_fk);
		   select ('Inserted completed successfully.')
		   end
	  end try
	  begin catch
	  select ('Data does not match');
	  end catch
      END
--update Track_Branch
      CREATE PROCEDURE usp_TrackBranch_Update
          @B_id_fk INT = null,
          @T_id_fk INT = null,
		  @new_B_id_fk INT = null,
          @new_T_id_fk INT = null
      AS
      BEGIN
	      if not exists (select T_id from track where t_id =@new_T_id_fk)
		  select'This Track Does Not exist.'
		  else if not exists (select B_id from branch where B_id =@new_B_id_fk)
		  select'This Branch Does Not exist.'
	      else if (@B_id_fk in (select t.B_id_fk from track_branch t) 
		           and @T_id_fk in (select t.T_id_fk from track_branch t))
		  begin
          UPDATE track_branch
          SET 
		  B_id_fk = coalesce (@new_B_id_fk,B_id_fk),
          T_id_fk =coalesce (@new_T_id_fk,T_id_fk)
          WHERE B_id_fk = @B_id_fk AND T_id_fk = @T_id_fk;
		  end
		  else
		  select 'This id is not exist'
      END
--delete from Track_Branch
   CREATE PROCEDURE sp_TrackBranch_Delete
       @B_id_fk INT = null,
       @T_id_fk INT = null
      AS
      BEGIN
	  if (@B_id_fk in (select t.B_id_fk from track_branch t) 
	      and @T_id_fk in (select t.T_id_fk from track_branch t))
          begin
		   DELETE FROM Track_Branch
           WHERE B_id_fk = @B_id_fk AND T_id_fk = @T_id_fk;
          END
	      else 
	      select 'This Track is Not Exist in This Branch'
      END

--1- sp select all from student_phone
create proc getstdphone
as
select * from student_phone


--select based on st_id
create proc GetStudentdPhonebyId @id int
as
begin
if @id is not null and @id in (select st_id from student_phone)
begin
select * from student_phone 
where st_id = @id
end
else 
select NULL as st_id , NULL as phone , 'This Id Not Found' as message
end

--2- sp insert into student_phone

create proc InsStdPhone @phone int , @id int
as
begin
if @id is not null and @id in(select st_id from student)
begin
insert into student_phone (st_id, phone)
values (@id, @phone)
end
else  
begin 
 select'This Student Does Not Exist.'
end
end
 
 

--3- update Student_phone
create proc AddPhone  @st_id  int , @newphone int 
as
begin
if exists (select st_id from student_phone)
begin
update student_phone
set
 phone = @newphone
where st_id = @st_id
end
else 
select ' This is Invalid ID'
end

--delete from student_phone 

create proc delphone @id int
as
begin
	if @id is not null and @id in (select st_id from student_phone)
	begin
		delete from student_phone
		where st_id = @id
	end
	else 
	select ' Can not Delete Invalid ID' 
end


-----------------------------------------------------------------------------------------------
--Table << Student_Exam_Question 
--1- select all 
create proc  GetstdgradeTernary
as
select * from Student_Exam_Question

--select based on st_id onlyy
create proc GetstdgradeTernarybySt_ID 
@st_id int 
as
begin 
select * from Student_Exam_Question 
where st_id =@st_id  
end

--select based on 3 PK
create proc GetstdgradeTernaryby3_IDs @id int  , @ex_id int  ,@q_id int 
as
begin 
if( @id is not null and @id  in (select st_id from  Student_Exam_Question) 
and @ex_id is not null and @ex_id  in (select ex_id from Exam_has_Quesstion) 
and @q_id is not null and @q_id  in (select Q_id from Student_Exam_Question)
)
begin 
select * from Student_Exam_Question
end 
else 
select 'Not Found This ID'
end

--sp insert 
---Not test yet---
create proc InsGradeTernary @St_id int , @ex_id int   , @Q_id int , @grade int ,@answer varchar(20) 
as
begin
if (@st_id not in  (select St_id from student where St_id = @st_id) and
    @ex_id not in  (select ex_id from Exam where ex_id = @ex_id) and                                               
	@Q_id  not in   (select Q_id from Question where Q_id = @st_id))	
	select'Invalid Data'
else
begin
insert into Student_Exam_Question ( st_id , ex_id , Q_id, grade, Answer) 
values(@st_id , @ex_id , @Q_id, @grade, @answer)
end
end

--sp update Grade
 create proc updateGradeTernary  @st_id int , @ex_id int   , @Q_id int , @grade int 
 as
 if exists (select st_id from Student_Exam_Question where
             st_id = @st_id and ex_id =@ex_id and Q_id =@Q_id)      
 begin 
 update Student_Exam_Question 
 set 
 grade = @grade 
 where st_id  = @st_id and ex_id =@ex_id and Q_id =@Q_id
 select 'Update successfully '
 end
 else 
 begin
 select  ' Can not update Invalid ID'
 end

 --Update answer 
 create proc updateanswerTernary  @st_id int , @ex_id int   , @Q_id int , @answer varchar(20) 
 as
 if exists (select st_id from Student_Exam_Question where
             st_id = @st_id and ex_id =@ex_id and Q_id =@Q_id)      
 begin 
 update Student_Exam_Question 
 set 
 answer = @answer 
 where st_id  = @st_id and ex_id =@ex_id and Q_id =@Q_id
 select 'Update successfully '
 end
 else 
 begin
 select  'Can not update Invalid ID'
 end

 ----sp delete
 create proc deleteGradeTernary  @st_id int , @ex_id int   , @Q_id int 
 as
 if exists(select 1 from Student_Exam_Question where 
           st_id  = @st_id and ex_id =@ex_id and Q_id =@Q_id)
 begin
 delete from Student_Exam_Question
 where st_id = @st_id and ex_id = @ex_id and Q_id=@Q_id
 select 'Delete Successfully ' 
 end
 else
 begin
 select ' Invalid ID, Can Not Delete'
 end

--------------------------------------------------------------------------------------------------

--Table Exam

--1- sp select all without any condition
create proc selexam
as
select * from Exam

-- select based on ex_id
create proc GetExamDatabyId @ex_id int
as
begin
if @ex_id is not null and @ex_id in(select ex_id from Exam)
select * from Exam
else if not exists (select ex_id from Exam where ex_id=@ex_id)
select ' This Exam Not found'
else
select 'Invalid Exaam ID '
end

--2-sp insert 
create proc InsertExam @ex_id int , @ex_name varchar(50) , @ex_date date , @crs_id int , @totalscore int
as
begin
begin try 
if  exists(select ex_id from exam where ex_id=@ex_id)
select'Dublicate Exam id'
else if not exists(select c_id from course where c_id=@crs_id)
select'corse id does not exist'
else
begin
insert into Exam (ex_id , ex_name , ex_date , c_id , total_score)
values(@ex_id , @ex_name , @ex_date , @crs_id , @totalscore)
end
end try 
begin catch
select 'ERROR!!'
end catch
end

--sp update 
create proc updateExam @ex_id int  , @ex_name varchar(50) , @ex_date date , @crs_id int , @totalscore int
as
 begin
 begin try
 if not exists (select 1 from Exam where ex_id = @ex_id)
 select'Exam does not exist.'
 else if not exists (select C_id from course where C_id=@crs_id)
 select'This course dose not exist'
 else if exists (select 1 from Exam where ex_id=@ex_id and ex_name=@ex_name
                                      and ex_date=@ex_date and c_id=@crs_id and total_score=@totalscore)
 select ' This Record already exists' 
 else
 begin
update Exam
	set 
	ex_name = Isnull(@ex_name,ex_name) ,
	ex_date = Isnull(@ex_date, ex_date) ,
	c_id = Isnull(@crs_id, c_id),
	total_score = Isnull(@totalscore,total_score)
	where ex_id = @ex_id 
select ' Update Successfully'
end 
end try
begin catch
select 'ERROR!!'
end catch
end


--delete 
create proc delExam  @ex_id int
as
begin
if @ex_id is not null and @ex_id  in (select ex_id from Exam )
begin
delete from Exam 
where ex_id  = @ex_id 
select 'Delete Exam successfully'
end
else 
begin
select ' This Exam Not Found ' 
end
end

--Exam_has_Quesstion procesdures
--select
CREATE Procedure ExQ_get_sp @ex_id int=null, @Q_id int=null
AS
BEGIN
if exists ( select 1 from Exam_has_Quesstion where ex_id = @ex_id and Q_id = @Q_id)
   begin
    SELECT * FROM Exam_has_Quesstion
	WHERE ex_id = isnull(@ex_id,ex_id) AND Q_id = isnull(@Q_id, Q_id)
	end
  else
  select'This Record Does not exist.'
END

--insert
CREATE PROCEDURE ExQ_Insert @ex_id int, @Q_id int
AS
BEGIN
    IF EXISTS(SELECT 1 FROM Exam_has_Quesstion WHERE ex_id = @ex_id AND Q_id = @Q_id)
	 BEGIN
	 SELECT 'this key already Exists'
	 END
	 else if not exists  (select ex_id from Exam where ex_id =@ex_id)
	 select 'This Exam is not exist.'
	 else if not exists  (select q_id from Question where Q_id =@Q_id)
	 select 'This Question is not exist.'
	 else
    INSERT INTO Exam_has_Quesstion(ex_id, Q_id)
    VALUES (@ex_id, @Q_id)
END

--delete
CREATE PROCEDURE ExQ_Delete @ex_id int, @Q_id int 
AS
BEGIN
    if exists ( select ex_id from Exam_has_Quesstion where ex_id =@ex_id and Q_id = @Q_id)
	begin
    DELETE FROM Exam_has_Quesstion
    WHERE ex_id = @ex_id AND Q_id = @Q_id
	end
	else
	select'This Record Does Not Exist.'
END

--update
CREATE PROCEDURE ExQ_Update @old_ex_id int ,@old_Q_id int, @new_ex_id int=null, @new_Q_id int=null
AS
BEGIN try
    IF @new_ex_id IS NOT NULL AND @new_Q_id IS NOT NULL
    BEGIN
        IF EXISTS (
            SELECT 1 
            FROM Exam_has_Quesstion
            WHERE ex_id = @new_ex_id AND Q_id = @new_Q_id
        )
		BEGIN
            Select 'New composite key already exists.'
        END
		else if not exists  (select ex_id from Exam where ex_id =@old_ex_id)
		select 'This Exam is not exist.'
		else if not exists  (select q_id from Question where Q_id =@old_Q_id)
		select 'This Question is not exist.'
		else
		begin
        UPDATE Exam_has_Quesstion
        SET ex_id = @new_ex_id,
           Q_id = @new_Q_id       
        WHERE ex_id = @old_ex_id AND Q_id = @old_Q_id
		end
     END 
End try
begin catch
		select'ERROR! Invalid Data.'
end catch

-------------
--Question procedures
--select
CREATE PROCEDURE Q_Get_sp @Q_id int =null
AS
BEGIN
if exists (select 1 from Question where Q_id = @Q_id)
   begin
    SELECT * FROM Question
	WHERE Q_id = isnull(@Q_id,Q_id)
	end
	else
	select'This Record Does Not Exist.'
END

--insert
CREATE PROCEDURE Q_Insert @Q_id int, @type varchar(20),@title nvarchar(max),@model_ans nvarchar(max),@c_id int
AS
begin
BEGIN try
    IF EXISTS(SELECT 1 FROM Question WHERE Q_id = @Q_id)
	BEGIN
	SELECT 'this key already Exists'
	END
    INSERT INTO Question(Q_id, type,title,model_answer,c_id)
    VALUES (@Q_id, @type, @title, @model_ans, @c_id)
END try
begin catch
 select'ERROR! Invalid Data.'
end catch
end

--delete
CREATE PROCEDURE Q_Delete @Q_id int
AS
BEGIN
   if exists (select 1 from Question where Q_id=@Q_id)
   begin
    DELETE FROM Question
    WHERE Q_id = @Q_id
   end
	else
	select'This Record Does not exist.'
END

--update 
CREATE PROCEDURE Q_Update @Q_id int, @type varchar(20)=null, @title nvarchar(max)=null, @model_ans nvarchar(max)=null, @c_id int=null
AS
BEGIN
    if not exists (select 1 from Question where Q_id = @Q_id)
	select'This Record Does Not Exist.'
	else if exists (select 1 from course where c_id= @C_id)
	begin
    UPDATE Question
    SET type = isnull(@type, type),
	    title = isnull(@title, title),
		model_answer = isnull(@model_ans, model_answer),
		c_id = isnull(@c_id, c_id)        
    WHERE Q_id = @Q_id
	end
END


----------------
--Question_choice procedures
--select
CREATE PROCEDURE QCh_Get @Q_id int=null, @choice varchar(20)=null
AS
BEGIN
if exists (select 1 from Question_choice where Q_id=@Q_id and choice=@choice)
begin
    SELECT * FROM Question_choice
	WHERE Q_id = ISNULL(@Q_id, Q_id) AND choice = ISNULL(@choice, choice)
end
else 
select'This Record Does Not Exist'
END

--insert
CREATE PROCEDURE QCh_Insert @Q_id int, @choice varchar(20), @text nvarchar(max)
AS
BEGIN
    IF EXISTS(SELECT 1 FROM Question_choice WHERE Q_id= @Q_id AND choice = @choice)
	BEGIN
	SELECT 'this key already exists'
	END
	else if exists (select 1 from Question where Q_id = @Q_id)
	begin
    INSERT INTO Question_choice( Q_id, choice, textOfChoice)
    VALUES (@Q_id, @choice, @text)
	end
	else
	select'This Question Does Not Exist.'
END

--delete
CREATE PROCEDURE QCh_Delete @Q_id int, @choice varchar(20)
AS
BEGIN
IF EXISTS(SELECT 1 FROM Question_choice WHERE Q_id= @Q_id AND choice = @choice)
  begin
    DELETE FROM Question_choice
    WHERE Q_id = @Q_id AND choice = @choice
  end
  else 
  select'Record you try to delete does not exist.'
END

--update
CREATE PROCEDURE QCh_Update @Q_id int, @choice varchar(20), @text nvarchar(max)
AS
BEGIN    
   IF Not EXISTS(SELECT 1 FROM Question_choice WHERE Q_id= @Q_id AND choice = @choice) 
   select'This Record you trying to update does not exist.'
   else if not exists (select Q_id from Question where Q_id = @Q_Id) 
   select'This Question Does Not Exist.'
   else
   begin
    UPDATE Question_choice
    SET textOfChoice = isnull(@text, textOfChoice) 
    WHERE Q_id = @Q_id AND choice = @choice
    end
END
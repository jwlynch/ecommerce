<master>
  <property name="title">Your Account</property>
  <property name="context_bar">@context_bar@</property>
  <property name="signatory">@ec_system_owner@</property>

  <include src="toolbar" current_location="your-account">


<blockquote>
  <form method="post" action="update-user-classes-2">
    <if @user_classes_need_approval@ true>
      <p>Submit a request to be in the following user classes:</p>
    </if>
    <else>
      <p>Select the user classes you belong in:</p>
    </else>
    <blockquote>
      @user_class_select_list@
    </blockquote>
    <center>
      <input type="submit" value="Done">
    </center>
  </form>
</blockquote>

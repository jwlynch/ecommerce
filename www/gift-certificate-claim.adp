<master src="default-ec-master">
<property name="title">Claim a Gift Certificate</property>

<h2>Claim a Gift Certificate</h2>

<form method="post" action="gift-certificate-claim-2">

  <blockquote>
    <p>If you've received a gift certificate, enter the claim check
      below in order to put the funds into your gift certificate
      account.</p>

    <p>If you've entered it before, you don't need to do so again.
      The funds are already in your account.</p>

    <p>Claim Check:</p>
    <input type="text" name="claim_check" size="20" maxlength="30">
    <input type="hidden" name="address_id" value="@address_id@">
    <input type="submit" value="Continue">
  </blockquote>

</form>

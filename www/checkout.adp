<master src="default-ec-master"></master>
<property name="title">Completing Your Order</property>
<property name="navbar">checkout {Select Shipping Address}</property>

<h2>Select Your Shipping Address</h2>

<blockquote>

  <if @shipping_required@ >
    <p><b>Please choose your shipping address.</b></p>

    <blockquote>
      <table>
	<if @addresses:rowcount@ ne 0>
	  <p>You can select an address listed below or enter a new address.</p>
	</if>
	<multiple name="addresses">
	  <if @addresses.rownum@ odd>
	    <tr>
	  </if>
	  <else>
	    <tr bgcolor="#eeeeee">
	  </else>
	  <td>
	    @addresses.formatted@
	  </td>
	  <td>
	    <table>
	      <tr>
		<td>
		  <form method="post" action="checkout-2">
		    @addresses.use@
		    <input type="submit" value="Use"></input>
		  </form>
		</td>
		<td>
		  <form method="post" action="address">
		    @addresses.edit@
		    <input type="submit" value="Edit"></input>
		  </form>
		</td>
		<td>
		  <form method="post" action="delete-address">
		    @addresses.delete@
		    <input type="submit" value="Delete"></input>
		  </form>
		</td>
	      </tr>
	    </table>
	  </td>
	</tr>
	  <tr>
	    <td>
	      &nbsp;
	    </td>
	  </tr>
	</multiple>
      </table>
    </blockquote>

    <table>
      <tr>
	<td>
	  <form method="post" action="address">
	    @hidden_form_vars@
	    <input type="submit" value="Enter a new U.S. address">
	  </form>
	</td>
	<td>
	  or
	</td>
	<td>
	  <form method="post" action="address-international">
	    @hidden_form_vars@
	    <input type="submit" value="Enter a new INTERNATIONAL address">
	  </form>
	</td>
      </tr>
    </table>
  </if>
  <else>
    <p>Your order does not need a shipping address</p>
    <form method="post" action="checkout-2">
      @hidden_form_vars@
      <center>
	<input type="submit" value="Continue"></input>
      </center>
    </form>
  </else>
   
</blockquote>
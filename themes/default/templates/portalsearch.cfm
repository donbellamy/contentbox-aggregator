<cfparam name="args.title" default="" />
<cfparam name="args.titleLevel" default="2" />
<cfparam name="args.q" default="" />
<cfoutput>
<cfif len( args.title ) >
	<h#args.titleLevel#>#args.title#</h#args.titleLevel#>
</cfif>
#html.startForm( name="searchForm", action=ag.linkNews(), method="get" )#
<div class="input-group">
	#html.textField( name="q", placeholder="Search", value=args.q, class="form-control")#
	<span class="input-group-btn">
		<button class="btn btn-primary" type="submit"><i class="fa fa-search"></i></button>
	</span>
</div>
#html.endForm()#
</cfoutput>
# stuff done once per exucution--not depending on r
function InitWRE!(o::StrBootTest{T}) where T
	o.willfill = o.robust && o.bootstrapt

	o.Repl.kZ>1 && (o.numer_b = Vector{T}(undef,nrows(o.Repl.RRpar)))

	if o.willfill
		o.J⋂s = Array{T,3}(undef, o.N⋂, o.ncolsv, o.Repl.kZ)
		o.ARpars = Array{T,3}(undef, o.Repl.kZ, o.ncolsv, o.q)
		o.J⋂ARpars = Array{T,3}(undef, o.N⋂, o.ncolsv, o.q)
		o.Jc = [c==1 ?  Array{T,3}(undef,0,0,0) : Array{T,3}(undef, o.clust[c].N, o.ncolsv, o.q) for c ∈ 1:o.NErrClustCombs]
	end

	o.T1L = Matrix{T}(undef, o.DGP.kX, o.ncolsv)
	o.T1R = similar(o.T1L)
	o.β̈s = Matrix{T}(undef, o.Repl.kZ, o.ncolsv)
	o.As = Array{T,3}(undef, o.Repl.kZ, o.ncolsv, o.Repl.kZ)
	o.numerWRE = Matrix{T}(undef, o.dof, o.ncolsv)

	if isone(o.Repl.kZ)
		if o.liml
			o.YY₁₁ = similar(o.β̈s)
			o.YY₁₂ = similar(o.β̈s)
			o.YY₂₂   = similar(o.β̈s)
			o.YPXY₁₁ = similar(o.β̈s)
			o.YPXY₁₂ = similar(o.β̈s)
			o.YPXY₂₂ = similar(o.β̈s)
			o.YY₁₂YPXY₁₂ = similar(o.β̈s)
			o.x₁₁ = similar(o.β̈s)
			o.x₁₂ = similar(o.β̈s)
			o.x₂₁ = similar(o.β̈s)
			o.x₂₂ = similar(o.β̈s)
			o.κs = similar(o.β̈s)
		end
	else
		o.denomWRE = Array{T,3}(undef, o.q, o.ncolsv, o.q)
		if o.liml
			o.YY✻ = Array{T,3}(undef, o.Repl.kZ+1, o.ncolsv, o.Repl.kZ+1)
			o.YPXY✻ = similar(o.YY✻)
			o.κWRE = Array{T,3}(undef,1,o.ncolsv,1)
		else
			o.δnumer = similar(o.β̈s)
		end
		if o.bootstrapt && !o.robust
			o.YY✻ = Array{T,3}(undef, o.Repl.kZ+1, o.ncolsv, o.Repl.kZ+1)
		end
	end

	if o.bootstrapt
		if o.NFE>0 && !o.FEboot && (o.bootstrapt || !isone(o.κ) || o.liml)
			o.CT✻FEu₁           = Array{T,3}(undef, o.NFE, o.N✻, 1)
			o.CT✻FEU₂par        = Array{T,3}(undef, o.NFE, o.N✻, o.Repl.kZ)
			o.invFEwtCT✻FEu₁    = Array{T,3}(undef, o.NFE, o.N✻, 1)
			o.invFEwtCT✻FEU₂par = Array{T,3}(undef, o.NFE, o.N✻, o.Repl.kZ)
			o.CT✻FEU        = [i>0 ? view(o.CT✻FEU₂par       ,:,:,i) : view(o.CT✻FEu₁       ,:,:,1) for i ∈ 0:o.Repl.kZ]
			o.invFEwtCT✻FEU = [i>0 ? view(o.invFEwtCT✻FEU₂par,:,:,i) : view(o.invFEwtCT✻FEu₁,:,:,1) for i ∈ 0:o.Repl.kZ]
		end

		o.willfill &&
			(o.β̈v = Matrix{T}(undef, o.N✻, o.ncolsv))
	end

	o.S✻Xu₁         = Array{T,3}(undef, o.DGP.kX, o.N✻, 1)
	o.S✻XU₂         = Array{T,3}(undef, o.DGP.kX, o.N✻, o.kY₂)
	o.S✻XU₂par      = Array{T,3}(undef, o.DGP.kX, o.N✻, o.Repl.kZ) 
	o.invXXS✻Xu₁    = Array{T,3}(undef, o.DGP.kX, o.N✻, 1)
	o.invXXS✻XU₂par = Array{T,3}(undef, o.DGP.kX, o.N✻, o.Repl.kZ)
	o.S✻XU      = [i>0 ? view(o.S✻XU₂par     ,:,:,i) : view(o.S✻Xu₁     ,:,:,1) for i ∈ 0:o.Repl.kZ]
	o.invXXS✻XU = [i>0 ? view(o.invXXS✻XU₂par,:,:,i) : view(o.invXXS✻Xu₁,:,:,1) for i ∈ 0:o.Repl.kZ]

	if o.bootstrapt || o.liml || !isone(o.κ)
		o.S✻Zperpu₁                 = Array{T,3}(undef, o.DGP.kZperp, o.N✻, 1)
		o.S✻ZperpU₂par              = Array{T,3}(undef, o.DGP.kZperp, o.N✻, o.Repl.kZ)
		o.invZperpZperpS✻Zperpu₁    = Array{T,3}(undef, o.DGP.kZperp, o.N✻, 1)
		o.invZperpZperpS✻ZperpU₂par = Array{T,3}(undef, o.DGP.kZperp, o.N✻, o.Repl.kZ)
		o.S✻ZperpU              = [i>0 ? view(o.S✻ZperpU₂par             ,:,:,i) : view(o.S✻Zperpu₁             ,:,:,1) for i ∈ 0:o.Repl.kZ]
		o.invZperpZperpS✻ZperpU = [i>0 ? view(o.invZperpZperpS✻ZperpU₂par,:,:,i) : view(o.invZperpZperpS✻Zperpu₁,:,:,1) for i ∈ 0:o.Repl.kZ]

		o.S✻ZperpUv              = Matrix{T}(undef, o.DGP.kZperp, o.ncolsv)
		o.invZperpZperpS✻ZperpUv = Matrix{T}(undef, o.DGP.kZperp, o.ncolsv)

		if o.NFE>0 & !o.FEboot
			o.CT✻FEUv = Matrix{T}(undef, o.NFE, o.ncolsv)
			o.invFEwtCT✻FEUv = Matrix{T}(undef, o.NFE, o.ncolsv)
		end

		o.S✻u₁u₁       = Array{T,3}(undef, 1        , o.N✻, 1        )
		o.S✻U₂paru₁    = Array{T,3}(undef, o.Repl.kZ, o.N✻, 1        )
		o.S✻U₂parU₂par = Array{T,3}(undef, o.Repl.kZ, o.N✻, o.Repl.kZ)
		o.S✻UU = [i>0 ? j>0 ? view(o.S✻U₂parU₂par,i,:,j) : view(o.S✻U₂paru₁,i,:,1) : j>0 ? view(o.S✻U₂paru₁,j,:,1) : view(o.S✻u₁u₁,1,:,1) for i ∈ 0:o.Repl.kZ, j ∈ 0:o.Repl.kZ]

		o.S✻y₁paru₁     = Array{T,3}(undef, 1        , o.N✻, 1        )
		o.S✻Zu₁         = Array{T,3}(undef, o.Repl.kZ, o.N✻, 1        )
		o.S✻y₁parU₂par  = Array{T,3}(undef, 1        , o.N✻, o.Repl.kZ)
		o.S✻ZU₂par      = Array{T,3}(undef, o.Repl.kZ, o.N✻, o.Repl.kZ)
		o.S✻YU = [i>0 ? j>0 ? view(o.S✻ZU₂par,i,:,j) : view(o.S✻Zu₁,i,:,1) : j>0 ? view(o.S✻y₁parU₂par,1,:,j) : view(o.S✻y₁paru₁,1,:,1) for i ∈ 0:o.Repl.kZ, j ∈ 0:o.Repl.kZ]
		o.S✻YUfold = Array{T,3}(undef, o.Repl.kZ+1, o.N✻, o.Repl.kZ+1)
	end

	if o.granular
		if o.willfill
			o.S✻UMZperp = Array{T,3}(undef, o.Nobs, o.N✻, o.Repl.kZ+1)
			o.S✻UPX     = Array{T,3}(undef, o.Nobs, o.N✻, o.Repl.kZ  )
			o.crosstab✻ind = o.Nobs==o.N✻ ? Vector(diagind(FakeArray(o.N✻,o.N✻))) : LinearIndices(FakeArray(o.Nobs,o.N✻))[CartesianIndex.(1:o.Nobs, o.ID✻)]
			o.XinvXX = X₁₂B(o.Repl.X₁, o.Repl.X₂, o.Repl.invXX)
			o.PXZ    = X₁₂B(o.Repl.X₁, o.Repl.X₂, o.Repl.V)

			if isone(o.Nw)
				o.PXY✻ = Matrix{T}(undef, o.Nobs, o.ncolsv)
				o.S✻UMZperpv = Matrix{T}(undef, o.Nobs, o.ncolsv)
			end
		end
	else
		o.Repl.Zperp = o.DGP.Zperp = Matrix{T}(undef,0,0)  # drop this potentially large array

		o.S✻⋂XU₂     = Array{T,3}(undef, o.DGP.kX, o.N✻⋂, o.kY₂)
		o.S✻⋂XU₂par  = Array{T,3}(undef, o.DGP.kX, o.N✻⋂, o.Repl.kZ)
		o.invXXS✻XU₂ = Array{T,3}(undef, o.DGP.kX, o.N✻, o.kY₂)

		if o.bootstrapt || o.liml || !isone(o.κ)  
			o.S✻ZperpU₂ = Array{T,3}(undef, o.DGP.kZperp, o.N✻, o.kY₂)
			o.invZperpZperpS✻ZperpU₂ = Array{T,3}(undef, o.DGP.kZperp, o.N✻, o.kY₂)
		end

		o.S✻⋂XY₂      = o.DGP.S✻⋂XY₂     - o.DGP.S✻⋂XZperp     * o.DGP.invZperpZperpZperpY₂   - o.DGP.invZperpZperpZperpX' * (o.DGP.S✻⋂ZperpY₂   - o.DGP.S✻⋂ZperpZperp * o.DGP.invZperpZperpZperpY₂ )
		o.S✻⋂XX       = o.DGP.S✻⋂XX      - o.DGP.S✻⋂XZperp     * o.DGP.invZperpZperpZperpX    - o.DGP.invZperpZperpZperpX' * (o.DGP.S✻⋂XZperp'   - o.DGP.S✻⋂ZperpZperp * o.DGP.invZperpZperpZperpX  )
		o.S✻⋂XDGPZ    = o.DGP.S✻⋂XZpar   - o.DGP.S✻⋂XZperp     * o.DGP.invZperpZperpZperpZpar - o.DGP.invZperpZperpZperpX' * (o.DGP.S✻⋂ZperpZpar - o.DGP.S✻⋂ZperpZperp * o.DGP.invZperpZperpZperpZpar)
		o.S✻⋂Xy₁      = o.DGP.S✻⋂Xy₁     - o.DGP.S✻⋂XZperp     * o.DGP.invZperpZperpZperpy₁   - o.DGP.invZperpZperpZperpX' * (o.DGP.S✻⋂Zperpy₁   - o.DGP.S✻⋂ZperpZperp * o.DGP.invZperpZperpZperpy₁ )
		  S✻⋂ZperpX   = o.DGP.S✻⋂XZperp' - o.DGP.S✻⋂ZperpZperp * o.DGP.invZperpZperpZperpX
		o.DGP.restricted &&
			(o.S✻⋂X_DGPZR₁ = o.DGP.S✻⋂XZR₁ - o.DGP.S✻⋂XZperp     * o.DGP.invZperpZperpZperpZR₁  - o.DGP.invZperpZperpZperpX' * (o.DGP.S✻⋂ZperpZR₁  - o.DGP.S✻⋂ZperpZperp * o.DGP.invZperpZperpZperpZR₁ ))

		o.invXXS✻⋂XY₂    = o.DGP.invXX * o.S✻⋂XY₂ 
		o.invXXS✻⋂XX     = o.DGP.invXX * o.S✻⋂XX  
		o.invXXS✻⋂XDGPZ  = o.DGP.invXX * o.S✻⋂XDGPZ 
		o.invXXS✻⋂Xy₁    = o.DGP.invXX * o.S✻⋂Xy₁ 
		o.DGP.restricted &&
			(o.invXXS✻⋂XDGPZR₁ = o.DGP.invXX * o.S✻⋂X_DGPZR₁)

		_S✻ZperpY₂      = @panelsum(o.DGP.S✻⋂ZperpY₂, o.info✻_✻⋂)  # moments of variables _before_ FWL processing
		_S✻Zperpy₁      = @panelsum(o.DGP.S✻⋂Zperpy₁, o.info✻_✻⋂)
		_S✻ZperpDGPZpar = @panelsum(o.DGP.S✻⋂ZperpZpar, o.info✻_✻⋂)
		o.DGP.restricted &&
			(_S✻ZperpDGPZR₁  = @panelsum(o.DGP.S✻⋂ZperpZR₁, o.info✻_✻⋂))

		S✻ZperpZperp    = @panelsum(o.DGP.S✻⋂ZperpZperp, o.info✻_✻⋂)
		o.S✻XY₂         = @panelsum(o.S✻⋂XY₂   , o.info✻_✻⋂)
		o.S✻XX          = @panelsum(o.S✻⋂XX    , o.info✻_✻⋂)
		o.S✻XDGPZ       = @panelsum(o.S✻⋂XDGPZ, o.info✻_✻⋂)
		o.S✻Xy₁         = @panelsum(o.S✻⋂Xy₁, o.info✻_✻⋂)
		o.S✻ZperpX      = @panelsum(S✻⋂ZperpX, o.info✻_✻⋂)
		o.S✻ZperpY₂     = _S✻ZperpY₂ - S✻ZperpZperp * o.DGP.invZperpZperpZperpY₂
		o.S✻ZperpDGPZ   = _S✻ZperpDGPZpar - S✻ZperpZperp * o.DGP.invZperpZperpZperpZpar
		o.S✻Zperpy₁     = _S✻Zperpy₁ - S✻ZperpZperp * o.DGP.invZperpZperpZperpy₁
		if o.DGP.restricted
			o.S✻XZR₁        = @panelsum(o.S✻⋂X_DGPZR₁, o.info✻_✻⋂)
			o.S✻ZperpDGPZR₁ = @panelsum(o.DGP.S✻⋂ZperpZR₁ , o.info✻_✻⋂) - S✻ZperpZperp * o.DGP.invZperpZperpZperpZR₁
		end

		if o.NFE>0 && !o.FEboot && (o.liml || !isone(o.κ) || o.bootstrapt)
			  CT✻⋂FEX  = [crosstabFE(o, o.DGP.X₁, o.info✻⋂) crosstabFE(o, o.DGP.X₂, o.info✻⋂)]
			o.CT✻FEX   = @panelsum(CT✻⋂FEX, o.info✻_✻⋂)
			o.CT✻FEY₂  = crosstabFE(o, o.DGP.Y₂, o.info✻); o.CT✻FEU₂ = similar(o.CT✻FEY₂)
			o.CT✻FEZ   = crosstabFE(o, o.DGP.Z, o.info✻)
			o.CT✻FEy₁  = crosstabFE(o, o.DGP.y₁, o.info✻)
			o.DGP.restricted &&
				(o.CT✻FEZR₁ = crosstabFE(o, o.DGP.ZR₁, o.info✻))
		end

		((o.willfill) || o.liml || !o.robust || !isone(o.κ)) &&
			(S✻⋂ReplZX = (o.Repl.S✻⋂XZpar - o.DGP.S✻⋂XZperp * o.Repl.invZperpZperpZperpZpar - o.DGP.invZperpZperpZperpX' * (o.Repl.S✻⋂ZperpZpar - o.DGP.S✻⋂ZperpZperp * o.Repl.invZperpZperpZperpZpar))')

		if o.willfill
			o.info⋂_✻⋂ = panelsetup(o.ID✻⋂, o.subcluster+1:o.NClustVar)

			o.S⋂ReplZX = @panelsum(S✻⋂ReplZX, o.info⋂_✻⋂)
			S⋂ZperpX   = @panelsum(S✻⋂ZperpX, o.info⋂_✻⋂)
			o.S⋂Xy₁    = @panelsum(o.S✻⋂Xy₁, o.info⋂_✻⋂)

			_inds = o.subcluster>0 ?
							[CartesianIndex(j,i) for (j,v) ∈ enumerate(o.info⋂_✻⋂) for i ∈ v] :  # crosstab ∩,* is wide
							o.NClustVar == o.NBootClustVar ?
									[CartesianIndex(i,i) for i ∈ 1:o.N✻⋂] :  # crosstab *,∩ is square
									[CartesianIndex(i,j) for (j,v) ∈ enumerate(o.clust[o.BootClust].info) for i ∈ v]  # crosstab ∩,* is tall
			inds = [CartesianIndex(k,I) for I ∈ _inds for k ∈ 1:o.DGP.kX]
			o.crosstab⋂✻ind = LinearIndices(FakeArray(Tuple(max(inds...))...))[inds]

			o.S⋂XZperpinvZperpZperp = S⋂ZperpX' * o.DGP.invZperpZperp

			o.negS✻UMZperpX = [Array{T,3}(undef, o.DGP.kX, o.N⋂, o.N✻) for _ in 0:o.Repl.kZ]
			# o.T₀ = Vector{T}(undef, o.N⋂)
			# o.T₁ = Matrix{T}(undef, o.N⋂, o.N✻)
			# o.Q    = Array{T,3}(undef, o.N✻, o.N⋂, o.N✻)
			o.T₁ = Matrix{T}(undef, 1, o.N✻)
			o.Q    = Array{T,2}(undef, o.N✻, o.N✻)
			o.Qv = Matrix{T}(undef, o.N✻, o.ncolsv)
			o.NFE>0 && !o.FEboot && (o.CT⋂FEX = o.invFEwt .* @panelsum(CT✻⋂FEX, o.info⋂_✻⋂))
			o.S✻diagUX = similar(o.S✻⋂Xy₁)
		end

		if o.liml || !o.robust || !isone(o.κ)  # cluster-wise moments after FWL
			o.S✻Y₂Y₂     = o.DGP.S✻Y₂Y₂     - _S✻ZperpY₂'      * o.DGP.invZperpZperpZperpY₂   - o.DGP.invZperpZperpZperpY₂'   * o.S✻ZperpY₂
			o.S✻DGPZDGPZ = o.DGP.S✻ZparZpar - _S✻ZperpDGPZpar' * o.DGP.invZperpZperpZperpZpar - o.DGP.invZperpZperpZperpZpar' * o.S✻ZperpDGPZ
			o.S✻DGPZY₂   = o.DGP.S✻ZparY₂   - _S✻ZperpDGPZpar' * o.DGP.invZperpZperpZperpY₂   - o.DGP.invZperpZperpZperpZpar' * o.S✻ZperpY₂
			o.S✻DGPZy₁   = o.DGP.S✻Zpary₁   - _S✻ZperpDGPZpar' * o.DGP.invZperpZperpZperpy₁   - o.DGP.invZperpZperpZperpZpar' * o.S✻Zperpy₁   
			o.S✻Y₂y₁     = o.DGP.S✻Y₂y₁     - _S✻ZperpY₂'      * o.DGP.invZperpZperpZperpy₁   - o.DGP.invZperpZperpZperpY₂'   * o.S✻Zperpy₁
			o.S✻y₁y₁     = o.DGP.S✻y₁y₁     - _S✻Zperpy₁'      * o.DGP.invZperpZperpZperpy₁   - o.S✻Zperpy₁'                  * o.DGP.invZperpZperpZperpy₁
			o.DGP.restricted && 
				(o.S✻DGPZR₁y₁ = o.DGP.S✻ZR₁y₁ - _S✻ZperpDGPZR₁' * o.DGP.invZperpZperpZperpy₁ - o.DGP.invZperpZperpZperpZR₁' * o.S✻Zperpy₁)

			if o.Repl.restricted
				_S✻ZperpReplZR₁ = @panelsum(o.Repl.S✻⋂ZperpZR₁, o.info✻_✻⋂)
				_S✻⋂XReplZR₁    = @panelsum(o.Repl.S✻⋂XZR₁    , o.info✻_✻⋂)
				
				o.r₁S✻ReplZR₁Y₂     = o.r₁' * (o.Repl.S✻ZR₁Y₂ - _S✻ZperpReplZR₁' * o.DGP.invZperpZperpZperpY₂ - o.Repl.invZperpZperpZperpZR₁' * o.S✻ZperpY₂)
				o.r₁S✻ReplZR₁U₂ = similar(o.r₁S✻ReplZR₁Y₂)
				o.r₁S✻ReplZR₁X      = o.r₁' * (_S✻⋂XReplZR₁'  - _S✻ZperpReplZR₁' * o.DGP.invZperpZperpZperpX  - o.Repl.invZperpZperpZperpZR₁' * o.S✻ZperpX )
				o.r₁S✻ReplZR₁DGPZ   = o.r₁' * panelcross(o.Repl.ZR₁, o.DGP.Z, o.info✻)   
				o.r₁S✻ReplZR₁y₁     = o.r₁' * (o.Repl.S✻ZR₁y₁ - _S✻ZperpReplZR₁' * o.DGP.invZperpZperpZperpy₁ - o.Repl.invZperpZperpZperpZR₁' * o.S✻Zperpy₁)
				o.DGP.restricted &&
					(o.r₁S✻ReplZR₁DGPZR₁ = o.r₁' * panelcross(o.Repl.ZR₁, o.DGP.ZR₁, o.info✻))
			end

			_S✻ZperpReplZpar = @panelsum(o.Repl.S✻⋂ZperpZpar, o.info✻_✻⋂)
			_S✻ReplXZ        = @panelsum(o.Repl.S✻⋂XZpar    , o.info✻_✻⋂)

			o.S✻ReplZY₂      = o.Repl.S✻ZparY₂ - _S✻ZperpReplZpar' * o.DGP.invZperpZperpZperpY₂ - o.Repl.invZperpZperpZperpZpar' * o.S✻ZperpY₂
			o.S✻ReplZX       = _S✻ReplXZ'      - _S✻ZperpReplZpar' * o.DGP.invZperpZperpZperpX  - o.Repl.invZperpZperpZperpZpar' * o.S✻ZperpX
			o.S✻ReplZDGPZ    = panelcross(o.Repl.Z, o.DGP.Z, o.info✻)   
			o.S✻ReplZy₁      = o.Repl.S✻Zpary₁ - _S✻ZperpReplZpar' * o.DGP.invZperpZperpZperpy₁ - o.Repl.invZperpZperpZperpZpar' * o.S✻Zperpy₁
			
			if o.DGP.restricted
				_S✻⋂XDGPZR₁ = @panelsum(o.DGP.S✻⋂XZR₁, o.info✻_✻⋂)

				o.S✻ReplZDGPZR₁  = panelcross(o.Repl.Z, o.DGP.ZR₁, o.info✻)   
				o.S✻DGPZR₁Y₂     = o.DGP.S✻ZR₁Y₂  - _S✻ZperpDGPZR₁' * o.DGP.invZperpZperpZperpY₂  - o.DGP.invZperpZperpZperpZR₁' * o.S✻ZperpY₂
				o.S✻DGPZR₁DGPZR₁ = o.DGP.S✻ZR₁ZR₁ - _S✻ZperpDGPZR₁' * o.DGP.invZperpZperpZperpZR₁  - o.DGP.invZperpZperpZperpZR₁' * o.S✻ZperpDGPZR₁
				o.S✻DGPZR₁DGPZ   = o.DGP.S✻ZR₁Z   - _S✻ZperpDGPZR₁' * o.DGP.invZperpZperpZperpZpar - o.DGP.invZperpZperpZperpZR₁' * o.S✻ZperpDGPZ
				o.S✻DGPZR₁X      = _S✻⋂XDGPZR₁'   - _S✻ZperpDGPZR₁' * o.DGP.invZperpZperpZperpX   - o.DGP.invZperpZperpZperpZR₁' * o.S✻ZperpX
			end
		end

		o.invXXS✻XY₂   = @panelsum(o.invXXS✻⋂XY₂  , o.info✻_✻⋂)
		o.invXXS✻XX    = @panelsum(o.invXXS✻⋂XX   , o.info✻_✻⋂)
		o.invXXS✻XDGPZ = @panelsum(o.invXXS✻⋂XDGPZ, o.info✻_✻⋂)
		o.invXXS✻Xy₁   = @panelsum(o.invXXS✻⋂Xy₁, o.info✻_✻⋂)
		o.invZperpZperpS✻ZperpY₂   = o.DGP.invZperpZperp * o.S✻ZperpY₂ 
		o.invZperpZperpS✻ZperpX    = o.DGP.invZperpZperp * o.S✻ZperpX  
		o.invZperpZperpS✻Zperpy₁   = o.DGP.invZperpZperp * o.S✻Zperpy₁ 
		o.invZperpZperpS✻ZperpDGPZ = o.DGP.invZperpZperp * o.S✻ZperpDGPZ

		if o.DGP.restricted
			o.invXXS✻XDGPZR₁ = @panelsum(o.invXXS✻⋂XDGPZR₁, o.info✻_✻⋂)
			o.invZperpZperpS✻ZperpDGPZR₁ = o.DGP.invZperpZperp * o.S✻ZperpDGPZR₁
		end
	end
	nothing
end

function PrepWRE!(o::StrBootTest{T}) where T
	if o.null
		r₁ = [o.r₁ ; o.r]
	  EstimateIV!(o.DGP, o, o.jk, r₁)
	  MakeResidualsIV!(o.DGP, o)
	else
		r₁ = o.r₁
	end

	t✻!(o.S✻⋂XU₂, o.S✻⋂XX, o.DGP.Π̂ ) ; o.S✻⋂XU₂ .= o.S✻⋂XY₂ .- o.S✻⋂XU₂
	t✻!(o.S✻⋂XU₂par, o.S✻⋂XU₂, o.Repl.RparY)
	t✻!(o.S✻XU₂, o.S✻XX, o.DGP.Π̂ ); o.S✻XU₂ .= o.S✻XY₂ .- o.S✻XU₂
	t✻!(o.S✻XU₂par, o.S✻XU₂, o.Repl.RparY)
	t✻!(o.invXXS✻XU₂, o.DGP.invXX, o.S✻XU₂)
	t✻!(o.invXXS✻XU₂par, o.invXXS✻XU₂, o.Repl.RparY)
	if o.bootstrapt || o.liml || !isone(o.κ)
		t✻!(o.S✻ZperpU₂, o.S✻ZperpX, o.DGP.Π̂ ); o.S✻ZperpU₂ .= o.S✻ZperpY₂ .- o.S✻ZperpU₂
		o.invZperpZperpS✻ZperpU₂ .= o.invZperpZperpS✻ZperpY₂; t✻minus!(o.invZperpZperpS✻ZperpU₂, o.invZperpZperpS✻ZperpX, o.DGP.Π̂ )
		t✻!(o.S✻ZperpU₂par, o.S✻ZperpU₂, o.Repl.RparY)
		t✻!(o.invZperpZperpS✻ZperpU₂par, o.invZperpZperpS✻ZperpU₂, o.Repl.RparY)
	end

	o.S✻Xu₁ .= o.S✻Xy₁;  t✻minus!(o.S✻Xu₁, o.S✻XDGPZ, o.DGP.β̈ );  t✻plus!(o.S✻Xu₁, o.S✻XU₂, o.DGP.γ̈ )
	o.DGP.restricted &&
		t✻minus!(o.S✻Xu₁, o.S✻XZR₁, r₁)
	@panelsum!(o.S✻XU₂par, o.S✻⋂XU₂par, o.info✻_✻⋂)

	o.invXXS✻Xu₁ .= o.invXXS✻Xy₁;  t✻minus!(o.invXXS✻Xu₁, o.invXXS✻XDGPZ, o.DGP.β̈ );  t✻plus!(o.invXXS✻Xu₁, o.invXXS✻XU₂, o.DGP.γ̈ )
	o.DGP.restricted &&
		t✻minus!(o.invXXS✻Xu₁, o.invXXS✻XDGPZR₁, r₁)

	if o.liml || !isone(o.κ) || !o.robust
		S✻U₂y₁ = o.S✻Y₂y₁ - o.DGP.Π̂' * o.S✻Xy₁
		S✻ZU₂ = o.S✻ReplZY₂ - o.S✻ReplZX * o.DGP.Π̂
		t✻!(o.S✻ZU₂par, S✻ZU₂, o.Repl.RparY)
		Π̂S✻XÜ₂γ̈ = o.DGP.Π̂' * o.S✻XU₂ * o.DGP.γ̈
		S✻Ü₂Y₂ = o.S✻Y₂Y₂ - o.DGP.Π̂' * o.S✻XY₂
		S✻Y₂Ü₂γ̈ = S✻Ü₂Y₂' * o.DGP.γ̈

		S✻UUterm = o.S✻Y₂y₁ - o.S✻DGPZY₂' * view(o.DGP.β̈ ,:,1) - o.DGP.Π̂' * (o.S✻Xy₁  - o.S✻XDGPZ * o.DGP.β̈)
		o.S✻u₁u₁ .= o.S✻y₁y₁ .- (2 * o.S✻DGPZy₁ - o.S✻DGPZDGPZ * o.DGP.β̈ )'o.DGP.β̈  .+ (2 * S✻UUterm - Π̂S✻XÜ₂γ̈ + S✻Y₂Ü₂γ̈ )'o.DGP.γ̈ 
		o.S✻U₂paru₁ .= o.Repl.RparY' * (S✻UUterm + S✻Y₂Ü₂γ̈ - Π̂S✻XÜ₂γ̈ )
		o.S✻U₂parU₂par .= o.Repl.RparY' * (S✻Ü₂Y₂ - o.S✻XU₂' * o.DGP.Π̂) * o.Repl.RparY

		o.S✻y₁paru₁ .= o.S✻y₁y₁; t✻minus!(o.S✻y₁paru₁, o.S✻DGPZy₁', o.DGP.β̈ ); t✻plus!(o.S✻y₁paru₁, S✻U₂y₁', o.DGP.γ̈ )

		o.S✻Zu₁ .= o.S✻ReplZy₁; t✻minus!(o.S✻Zu₁, o.S✻ReplZDGPZ, o.DGP.β̈ ); t✻plus!(o.S✻Zu₁, S✻ZU₂, o.DGP.γ̈ )

		t✻!(o.S✻y₁parU₂par, S✻U₂y₁', o.Repl.RparY)

		if o.DGP.restricted
			r₁S✻DGPZR₁y₁ = r₁' * o.S✻DGPZR₁y₁
			o.S✻u₁u₁ .+= -2 .* r₁S✻DGPZR₁y₁ .+ r₁' * (o.S✻DGPZR₁DGPZR₁ * r₁) .+ 2 .* r₁' * (o.S✻DGPZR₁DGPZ * o.DGP.β̈ + (o.S✻DGPZR₁X * o.DGP.Π̂ - o.S✻DGPZR₁Y₂) * o.DGP.γ̈ )
			o.S✻U₂paru₁ .-= o.Repl.RparY' * (o.S✻DGPZR₁Y₂ - o.S✻DGPZR₁X * o.DGP.Π̂ )' * r₁
			o.S✻y₁paru₁ .-= r₁S✻DGPZR₁y₁
			t✻minus!(o.S✻Zu₁, o.S✻ReplZDGPZR₁, r₁)
		end

		if o.Repl.restricted
			o.r₁S✻ReplZR₁U₂ .= o.r₁S✻ReplZR₁Y₂; t✻minus!(o.r₁S✻ReplZR₁U₂, o.r₁S✻ReplZR₁X, o.DGP.Π̂ )
			o.S✻y₁paru₁ .-= o.r₁S✻ReplZR₁y₁;  t✻minus!(o.S✻y₁paru₁, o.r₁S✻ReplZR₁DGPZ, o.DGP.β̈ ); t✻plus!(o.S✻y₁paru₁, o.r₁S✻ReplZR₁U₂, o.DGP.γ̈ )
			t✻minus!(o.S✻y₁parU₂par,  o.r₁S✻ReplZR₁U₂, o.Repl.RparY)
			o.DGP.restricted &&
				t✻plus!(o.S✻y₁paru₁, o.r₁S✻ReplZR₁DGPZR₁, r₁)
		end

		@inbounds for i ∈ 0:o.Repl.kZ, j ∈ 0:i
			o.S✻YUfold[i+1,:,j+1] .= o.S✻YU[i+1,j+1] .+ o.S✻YU[j+1,i+1]
			o.S✻YUfold[j+1,:,i+1] .= o.S✻YUfold[i+1,:,j+1]
		end
	end

	if o.liml || !isone(o.κ) || o.bootstrapt
		o.S✻Zperpu₁              .= o.S✻Zperpy₁; t✻minus!(o.S✻Zperpu₁, o.S✻ZperpDGPZ, o.DGP.β̈ ); t✻plus!(o.S✻Zperpu₁, o.S✻ZperpU₂, o.DGP.γ̈ )
		o.invZperpZperpS✻Zperpu₁ .= o.invZperpZperpS✻Zperpy₁; t✻minus!(o.invZperpZperpS✻Zperpu₁, o.invZperpZperpS✻ZperpDGPZ, o.DGP.β̈ ); t✻plus!(o.invZperpZperpS✻Zperpu₁, o.invZperpZperpS✻ZperpU₂, o.DGP.γ̈ )
		if o.DGP.restricted
			t✻minus!(o.S✻Zperpu₁, o.S✻ZperpDGPZR₁, r₁)
			t✻minus!(o.invZperpZperpS✻Zperpu₁, o.invZperpZperpS✻ZperpDGPZR₁, r₁)
		end

		if o.NFE>0 && !o.FEboot
			o.CT✻FEU₂ .= o.CT✻FEY₂; t✻minus!(o.CT✻FEU₂, o.CT✻FEX, o.DGP.Π̂ )
			o.CT✻FEu₁ .= o.CT✻FEy₁; t✻minus!(o.CT✻FEu₁, o.CT✻FEZ, o.DGP.β̈ ); t✻plus!(o.CT✻FEu₁, o.CT✻FEU₂, o.DGP.γ̈ )
			t✻!(o.CT✻FEU₂par, o.CT✻FEU₂, o.Repl.RparY)
			o.DGP.restricted &&
				t✻minus!(o.CT✻FEu₁, o.CT✻FEZR₁, r₁)
			o.invFEwtCT✻FEu₁    .= o.invFEwt .* o.CT✻FEu₁
			o.invFEwtCT✻FEU₂par .= o.invFEwt .* o.CT✻FEU₂par
		end
	end


	if o.willfill
		@inbounds for j ∈ 0:o.Repl.kZ
			if o.Repl.Yendog[j+1]
				t✻!(o.negS✻UMZperpX[j+1], o.S⋂XZperpinvZperpZperp, o.S✻ZperpU[j+1])  # S_* diag⁡(U ̈_(∥j) ) Z_⊥ (Z_⊥^' Z_⊥ )^(-1) Z_(⊥g)^' X_(∥g)
				if iszero(j)  # - S_*  diag⁡(U ̈_(∥j) ) I_g^' X_(∥g)
					o.S✻diagUX .= o.S✻⋂Xy₁; t✻minus!(o.S✻diagUX, o.S✻⋂XDGPZ, o.DGP.β̈ ); t✻plus!(o.S✻diagUX, o.S✻⋂XU₂, o.DGP.γ̈ )
					o.DGP.restricted &&
						t✻minus!(o.S✻diagUX, o.S✻⋂X_DGPZR₁, r₁)
				else
					o.S✻diagUX .= view(o.S✻⋂XU₂par,:,:,j)
				end
				o.negS✻UMZperpX[j+1][o.crosstab⋂✻ind] .-= vec(o.S✻diagUX)
				o.NFE>0 && !o.FEboot &&
					t✻plus!(o.negS✻UMZperpX[j+1],  o.CT⋂FEX', o.CT✻FEU[j+1])  # CT_(*,FE) (U ̈_(∥j) ) (S_FE S_FE^' )^(-1) S_FE
			end
		end
	end
	nothing
end

function PrepWREGranular!(o::StrBootTest{T}) where T
	if o.null
		r₁ = [o.r₁ ; o.r]
	  EstimateIV!(o.DGP, o, o.jk, r₁)
	  MakeResidualsIV!(o.DGP, o)
  	o.Ü₂par = o.DGP.Ü₂[1] * o.Repl.RparY
	else
		r₁ = o.r₁
	end

	panelcross!(o.S✻Xu₁, o.DGP.X₁, o.DGP.X₂, o.DGP.u⃛₁[1], o.info✻)
	panelcross!(o.S✻XU₂par, o.DGP.X₁, o.DGP.X₂, o.Ü₂par, o.info✻)
	t✻!(o.invXXS✻Xu₁   , o.DGP.invXX, o.S✻Xu₁   )
	t✻!(o.invXXS✻XU₂par, o.DGP.invXX, o.S✻XU₂par)

	if o.bootstrapt || o.liml || !isone(o.κ)
		panelcross!(o.S✻Zperpu₁, o.DGP.Zperp, o.DGP.u⃛₁[1], o.info✻)
		panelcross!(o.S✻ZperpU₂par, o.DGP.Zperp, o.Ü₂par, o.info✻)
		t✻!(o.invZperpZperpS✻Zperpu₁, o.DGP.invZperpZperp, o.S✻Zperpu₁)
		t✻!(o.invZperpZperpS✻ZperpU₂par, o.DGP.invZperpZperp, o.S✻ZperpU₂par)
		if o.NFE>0 && !o.FEboot
			crosstabFE!(o, o.CT✻FEu₁    , o.DGP.u⃛₁[1], o.info✻)
			crosstabFE!(o, o.CT✻FEU₂par, o.Ü₂par     , o.info✻)
			o.invFEwtCT✻FEu₁ .= o.invFEwt .* o.CT✻FEu₁
			o.invFEwtCT✻FEU₂par .= o.invFEwt .* o.CT✻FEU₂par
		end
	end

	if o.liml || !o.robust || !isone(o.κ)
		panelcross!(o.S✻u₁u₁, o.DGP.u⃛₁[1], o.DGP.u⃛₁[1], o.info✻)
		panelcross!(o.S✻U₂paru₁, o.Ü₂par, o.DGP.u⃛₁[1], o.info✻)
		panelcross!(o.S✻U₂parU₂par, o.Ü₂par, o.Ü₂par, o.info✻)

		panelcross!(o.S✻y₁paru₁, o.Repl.y₁par, o.DGP.u⃛₁[1], o.info✻)
		panelcross!(o.S✻Zu₁, o.Repl.Z, o.DGP.u⃛₁[1], o.info✻)
		panelcross!(o.S✻y₁parU₂par, o.Repl.y₁par, o.Ü₂par, o.info✻)
		panelcross!(o.S✻ZU₂par, o.Repl.Z, o.Ü₂par, o.info✻)

		@inbounds for i ∈ 0:o.Repl.kZ, j ∈ 0:i
			o.S✻YUfold[i+1,:,j+1] .= o.S✻YU[i+1,j+1] .+ o.S✻YU[j+1,i+1]
			o.S✻YUfold[j+1,:,i+1] .= o.S✻YUfold[i+1,:,j+1]
		end
	end

	if o.willfill
		t✻!(view(o.S✻UMZperp,:,:,1            ), o.DGP.Zperp, view(o.invZperpZperpS✻Zperpu₁,:,:,1))
		t✻!(view(o.S✻UMZperp,:,:,2:o.Repl.kZ+1), o.DGP.Zperp, o.invZperpZperpS✻ZperpU₂par)
		t✻!(o.S✻UPX, o.XinvXX, o.S✻XU₂par)
		@inbounds for i ∈ 0:o.Repl.kZ  # precompute various clusterwise sums
			if iszero(i)
				o.S✻UMZperp[:,:,i+1][o.crosstab✻ind] .-= o.DGP.u⃛₁[1]  # subtract crosstab of observation by ∩-group of u
			else
				o.S✻UMZperp[:,:,i+1][o.crosstab✻ind] .-= view(o.Ü₂par,:,i)  # subtract crosstab of observation by ∩-group of u
			end
			o.NFE>0 && !o.FEboot &&
				(o.S✻UMZperp[:,:,i+1] .-= view(o.invFEwtCT✻FEU[i+1], o._FEID, :))  # CT_(*,FE) (U ̈_(parj) ) (S_FE S_FE^' )^(-1) S_FE
		end
  end
	nothing
end


# For WRE, and with reference to Y = [y₁ Z], given 0-based columns indexes within it, i, j, return all bootstrap realizations of 
# Y[:,i]'((1-κ)*M_Zperp-κ*M_Xpar)*Y[:,j] for κ constant across replications
# i can be a rowvector
# (only really the Hessian when we narrow Y to Z)
function HessianFixedkappa(o::StrBootTest{T}, is::Vector{S} where S<:Integer, j::Integer, κ::Number) where T
  dest = Matrix{T}(undef, length(is), o.ncolsv)
  @inbounds for i ∈ eachindex(is, axes(dest,1))
		_HessianFixedkappa!(o, dest, i, is[i], j, κ)
  end
  dest
end
function HessianFixedkappa!(o::StrBootTest{T}, dest::AbstractMatrix{T}, is::Vector{S} where S<:Integer, j::Integer, κ::Number) where T
  @inbounds for i ∈ eachindex(is, axes(dest,1))
		_HessianFixedkappa!(o, dest, i, is[i], j, κ)
  end
  dest
end

function _HessianFixedkappa!(o::StrBootTest, dest::AbstractMatrix, row::Integer, i::Integer, j::Integer, κ::Number)
  if !(o.Repl.Yendog[i+1] || o.Repl.Yendog[j+1])  # if both vars exog, result = order-0 term only, same for all draws
		!iszero(κ) && 
			(dest[row,:] .= dot(view(o.Repl.XZ,:,i), view(o.Repl.V,:,j)))
		if !isone(κ)
			if iszero(κ)
				dest[row,:] .= o.Repl.YY[i+1,j+1]
			else
				dest[row,:] .= κ .* dest[row,:] .+ (1 - κ) .* o.Repl.YY[i+1,j+1]
			end
		end
	else
		if !iszero(κ)  # repetitiveness in this section to maintain type stability
			if o.Repl.Yendog[i+1]
				t✻!(o.T1L, o.S✻XU[i+1], o.v)
				if iszero(i)
					o.T1L .+= o.Repl.Xy₁par
				else
					o.T1L .+= view(o.Repl.XZ,:,i)
				end
				if o.Repl.Yendog[j+1]
					t✻!(o.T1R, o.invXXS✻XU[j+1], o.v)
					if iszero(j)
						o.T1R .+=  o.Repl.invXXXy₁par
					else
						o.T1R .+= view(o.Repl.V,:,j)
					end
					coldot!(dest, row, o.T1L, o.T1R)
				else
					t✻!(view(dest,row,:), o.T1L', view(o.Repl.V,:,j))  # coldot!(dest, row, T1L, view(o.Repl.V,:,j))
				end
			else
				if o.Repl.Yendog[j+1]
					t✻!(o.T1R, o.invXXS✻XU[j+1], o.v)
					if iszero(j)
						o.T1R .+=  o.Repl.invXXXy₁par
					else
						o.T1R .+= view(o.Repl.V,:,j)
					end
					t✻!(view(dest,row,:), o.T1R', view(o.Repl.XZ,:,i))
				else
					dest[row,:] .= dot(view(o.Repl.V,:,j), view(o.Repl.XZ,:,i))
				end
			end
		end
		if !isone(κ)
			if o.Repl.Yendog[i+1]
				t✻!(o.invZperpZperpS✻ZperpUv, o.invZperpZperpS✻ZperpU[i+1], o.v)
				t✻!(             o.S✻ZperpUv,              o.S✻ZperpU[j+1], o.v)
				if o.NFE>0 && !o.FEboot
					t✻!(       o.CT✻FEUv,        o.CT✻FEU[i+1], o.v)
					t✻!(o.invFEwtCT✻FEUv, o.invFEwtCT✻FEU[j+1], o.v)
				end
				if iszero(κ)
					dest[row,:] .= o.Repl.YY[i+1,j+1]; t✻plus!(view(dest,row,:), o.v', view(o.S✻YUfold,i+1,:,j+1))
					coldotminus!(dest, row, o.invZperpZperpS✻ZperpUv, o.S✻ZperpUv)  # when is this term 0??
					coldotplus!(dest, row, o.v, o.S✻UU[i+1,j+1], o.v)
					o.NFE>0 && !o.FEboot &&
						coldotminus!(dest, row, o.CT✻FEUv, o.invFEwtCT✻FEUv)
				else
					_dest = t✻(view(o.S✻YUfold,i+1,:,j+1)', o.v); _dest .+= o.Repl.YY[i+1,j+1]
					coldotminus!(_dest, 1, o.invZperpZperpS✻ZperpUv, o.S✻ZperpUv)
					coldotplus!(_dest, 1, o.v, o.S✻UU[i+1, j+1], o.v)
					o.NFE>0 && !o.FEboot &&
						coldotminus!(_dest, 1, o.CT✻FEUv, o.invFEwtCT✻FEUv)
					dest[row,:] .= κ .* dest[row,:] .+ (1 - κ) .* _dest
				end
			elseif iszero(κ)
				dest[row,:] .= o.Repl.YY[i+1,j+1]
			else
				dest[row,:] .= κ .* dest[row,:] .+ (1 - κ) .* o.Repl.YY[i+1,j+1]
			end
		end
  end
	nothing
end

# put threaded loops in functions to prevent compiler-perceived type instability https://discourse.julialang.org/t/type-inference-with-threads/2004/3
function FillingLoop1!(o::StrBootTest{T}, dest::Matrix{T}, i::Integer, j::Integer, _β̈ ::AbstractMatrix{T}) where T
	Threads.@threads for g ∈ 1:o.N⋂
		PXY✻ = [o.PXZ[g,i]]
		o.Repl.Yendog[i+1] && (PXY✻ = PXY✻ .+ view(o.S✻UPX,g,:,i)'o.v)

		if iszero(j)
			dest[g,:]   = dropdims(colsum(PXY✻ .* (o.DGP.y₁[g] .- view(o.S✻UMZperp,g,:,1)'o.v)); dims=1)
		elseif o.Repl.Yendog[j+1]
			dest[g,:] .-= dropdims(colsum(PXY✻ .* (o.Repl.Z[g,j] * _β̈ .- view(o.S✻UMZperp,g,:,j+1)'o.β̈v)); dims=1)
		else
			dest[g,:] .-= dropdims(colsum(PXY✻ .* (o.Repl.Z[g,j] * _β̈)); dims=1)
		end
	end
	nothing
end
function FillingLoop2!(o::StrBootTest{T}, dest::Matrix{T}, i::Integer, j::Integer, _β̈ ::AbstractMatrix{T}) where T
	Threads.@threads for g ∈ 1:o.N⋂
		S = o.info⋂[g]
		PXY✻ = o.Repl.Yendog[i+1] ? view(o.PXZ,S,i) .+ view(o.S✻UPX[:,:,i],S,:) * o.v :
												         reshape(view(o.PXZ,S,i), :, 1)

		if iszero(j)
			dest[g,:]   = dropdims(colsum(PXY✻ .* (o.DGP.y₁[S] .- view(o.S✻UMZperp,S,:,1) * o.v)); dims=1)
		else
			dest[g,:] .-= dropdims(colsum(PXY✻ .* (o.Repl.Yendog[j+1] ? o.Repl.Z[S,j] * _β̈ .- view(o.S✻UMZperp,S,:,j+1) * o.β̈v :
																														       o.Repl.Z[S,j] * _β̈                                       )); dims=1)
		end
	end
	nothing
end

# Workhorse for WRE CRVE sandwich filling
# Given a zero-based column index, i>0, and a matrix β̈s of all the bootstrap estimates, 
# return all bootstrap realizations of P_X * Z[:,i]_g ' û₁g^*b
# for all groups in the intersection of all error clusterings
# return value has one row per ⋂ cluster, one col per bootstrap replication
# that is, given i, β̈s = δ ̂_CRκ^(*), return, over all g, b (P_(X_∥ g) Z_(∥i)^(*b) )^' (M_(Z_⊥ ) y_(1∥)^(*b) )_g-(P_(X_∥ g) Z_(∥i)^(*b) )^' (M_(Z_⊥ ) Z_∥^(*b) )_g δ ̂_CRκ^(*b)
function Filling!(o::StrBootTest{T}, dest::AbstractMatrix{T}, i::Int64, β̈s::AbstractMatrix) where T
	if o.granular
		if o.Nw == 1  # create or avoid NxB matrix?
			t✻!(o.S✻UMZperpv, view(o.S✻UMZperp,:,:,1), o.v); o.S✻UMZperpv .= o.DGP.y₁ .- o.S✻UMZperpv
			if o.Repl.Yendog[i+1]
				o.PXY✻ .= view(o.PXZ,:,i); t✻plus!(o.PXY✻, view(o.S✻UPX,:,:,i), o.v)
				panelcoldot!(dest, o.S✻UMZperpv, o.PXY✻, o.info⋂)
				@inbounds for j ∈ 1:o.Repl.kZ
					_β̈  = view(β̈s,j:j,:)
					o.β̈v .= o.v .* _β̈ 
					t✻!(o.S✻UMZperpv, view(o.Repl.Z,:,j), _β̈ )
					o.Repl.Yendog[j+1] &&
						(t✻minus!(o.S✻UMZperpv, view(o.S✻UMZperp,:,:,j+1), o.β̈v))
					panelcoldotminus!(dest, o.S✻UMZperpv, o.PXY✻, o.info⋂)
				end
			else
				PXY✻ = view(o.PXZ,:,i)
				panelsum!(dest, o.S✻UMZperpv, PXY✻, o.info⋂)
				@inbounds for j ∈ 1:o.Repl.kZ
					_β̈  = view(β̈s,j:j,:)
					o.β̈v .= o.v .* _β̈ 
					t✻!(o.S✻UMZperpv, view(o.Repl.Z,:,j), _β̈ )
					o.Repl.Yendog[j+1] &&
						(t✻minus!(o.S✻UMZperpv, view(o.S✻UMZperp,:,:,j+1), o.β̈v))
					panelsumminus!(dest, o.S✻UMZperpv, PXY✻, o.info⋂)
				end
			end
		else  # create pieces of each N x B matrix one at a time
			_β̈ = view(β̈s,1:1,:)  # hack to create for j=0
			@inbounds for j ∈ 0:o.Repl.kZ
				j>0 && (o.β̈v = o.v .* (_β̈ = view(β̈s,j:j,:)))
				(o.purerobust ? FillingLoop1! : FillingLoop2!)(o, dest, i, j, _β̈ )
			end
		end
	else  # coarse error clustering
		# (P_(X_∥ g) Z_∥^* )^' (M_(Z_⊥ ) y_(1∥)^* )_g
		F1₀ = view(o.Repl.V,:,i)  # o.DGP.kX
		F1₁ = view(o.invXXS✻XU₂par,:,:,i)  # o.DGP.kX x o.N✻  zero when FEboot??
		
		@inbounds for g ∈ 1:o.N⋂
			F2₀ = view(o.S⋂Xy₁,:,g,1) # o.DGP.kX x o.N⋂ x 1
			F2₁ = view(o.negS✻UMZperpX[1],:,g,:) # o.DGP.kX x o.N⋂ x o.N✻

			T₀ = F2₀'F1₀
			t✻!(o.T₁, F1₀', F2₁)

			dest[g,:] .= T₀
			if o.Repl.Yendog[i+1]  # add terms that are zero only if Zpar[i] is exogenous, i.e. if a null refers only to exogenous variables
				t✻minus!(o.T₁, F2₀', F1₁)
				t✻!(o.Q, F1₁', F2₁)
				t✻!(o.Qv, o.Q, o.v)
			end
			t✻minus!(view(dest,g:g,:), o.T₁, o.v)  # 0th- & 1st-order terms

			# -(P_(X_∥ g) Z_∥^* )^' (M_(Z_⊥ ) Z_∥^(*b) )_g δ ̂_CRκ^*
			for j ∈ 1:o.Repl.kZ
				F2₀t = view(o.S⋂ReplZX,j,g,:)  # o.N⋂ x o.DGP.kX
				T₀ = F2₀t'F1₀
				o.β̈v .= o.v .* view(β̈s,j,:)'

				t✻minus!(view(dest,g,:), T₀, view(β̈s,j,:))
				if o.Repl.Yendog[i+1] || o.Repl.Yendog[j+1]
					t✻!(o.T₁, F2₀t', F1₁)
					if o.Repl.Yendog[j+1]
						F2₁ = view(o.negS✻UMZperpX[j+1],:,g,:)
						t✻minus!(o.T₁, F1₀', F2₁)
						t✻!(o.Q, F1₁', F2₁)
						t✻minus!(o.Qv, o.Q, o.β̈v)
					end
					t✻minus!(view(dest,g:g,:), o.T₁, o.β̈v)
				end
			end
			coldotminus!(dest, g, o.v, o.Qv)
		end
		# F1₀ = view(o.Repl.V,:,i)  # o.DGP.kX
		# F1₁ = view(o.invXXS✻XU₂par,:,:,i)  # o.DGP.kX x o.N✻  zero when FEboot??
		# F2₀ = o.S⋂Xy₁' # 1 x o.N⋂ x o.DGP.kX
		# F2₁ = o.negS✻UMZperpX[1] # o.DGP.kX x o.N⋂ x o.N✻

		# t✻!(reshape(o.T₀, 1, o.N⋂, 1    ), F2₀, F1₀)
		# t✻!(reshape(o.T₁, 1, o.N⋂, o.N✻), F1₀', F2₁)

		# dest .= o.T₀
		# if o.Repl.Yendog[i+1]  # add terms that are zero only if Zpar[i] is exogenous, i.e. if a null refers only to exogenous variables
		# 	t✻minus!(o.T₁, dropdims(F2₀; dims=1), F1₁)
		# 	t✻minus!(dest, o.T₁, o.v)  # 0th- & 1st-order terms
		# 	t✻!(o.Q, F1₁', F2₁)
		# 	# colquadformminus3!(dest, o.v, o.Q, o.v)
		# 	@inbounds for g ∈ 1:o.N⋂
		# 		colquadformminus!(dest, g, o.v, view(o.Q,:,g,:), o.v)
		# 	end
		# else
		# 	t✻minus!(dest, o.T₁, o.v)  # 0th- & 1st-order terms
		# end

		# # -(P_(X_∥ g) Z_∥^* )^' (M_(Z_⊥ ) Z_∥^(*b) )_g δ ̂_CRκ^*
		# @inbounds for j ∈ 1:o.Repl.kZ
		# 	F2₀ = view(o.S⋂ReplZX,j,:,:)  # o.N⋂ x o.DGP.kX
		# 	t✻!(o.T₀, F2₀, F1₀)
		# 	o.β̈v .= o.v .* (_β̈ = -view(β̈s,j:j,:))

		# 	t✻plus!(dest, o.T₀, _β̈ )
		# 	if o.Repl.Yendog[j+1]
		# 		F2₁ = o.negS✻UMZperpX[j+1]
		# 		t✻!(reshape(o.T₁, 1, o.N⋂, o.N✻), F1₀', F2₁)
		# 		t✻minus!(o.T₁, F2₀, F1₁)
		# 		t✻minus!(dest, o.T₁, o.β̈v)  # "minus" because S✻UMZperpX is stored negated as F2₁=negS✻UMZperpX[j+1]
		# 		t✻!(o.Q, F1₁', F2₁)
		# 		for g ∈ 1:o.N⋂
		# 			colquadformminus!(dest, g, o.v, view(o.Q,:,g,:), o.β̈v)
		# 		end
		# 		# colquadformminus3!(dest, o.v, o.Q, o.β̈v)
		# 	elseif o.Repl.Yendog[i+1]
		# 		t✻!(o.T₁, F2₀, F1₁)
		# 		t✻plus!(dest, o.T₁, o.β̈v)
		# 	end
		# end
  end
  nothing
end

function MakeWREStats!(o::StrBootTest{T}, w::Integer) where T
  if isone(o.Repl.kZ)  # optimized code for 1 retained coefficient in bootstrap regression
		_As = view(o.As,:,:,1)
		if o.liml
			HessianFixedkappa!(o, o.YY₁₁  , [0], 0, zero(T))  # κ=0 => Y*MZperp*Y
			HessianFixedkappa!(o, o.YY₁₂  , [0], 1, zero(T))
			HessianFixedkappa!(o, o.YY₂₂  , [1], 1, zero(T))
			HessianFixedkappa!(o, o.YPXY₁₁, [0], 0, one(T) )  # κ=1 => Y*PXpar*Y
			HessianFixedkappa!(o, o.YPXY₁₂, [0], 1, one(T) )
			HessianFixedkappa!(o, o.YPXY₂₂, [1], 1, one(T) )
			o.YY₁₂YPXY₁₂ .= o.YY₁₂ .* o.YPXY₁₂
			o.x₁₁ .= o.YY₂₂ .* o.YPXY₁₁ .- o.YY₁₂YPXY₁₂      # elements of o.YY✻^-1 * o.YPXY✻ up to factor of det(o.YY✻)
			o.x₁₂ .= o.YY₂₂ .* o.YPXY₁₂ .- o.YY₁₂ .* o.YPXY₂₂
			o.x₂₁ .= o.YY₁₁ .* o.YPXY₁₂ .- o.YY₁₂ .* o.YPXY₁₁
			o.x₂₂ .= o.YY₁₁ .* o.YPXY₂₂ .- o.YY₁₂YPXY₁₂
			o.κs .= (o.x₁₁ .+ o.x₂₂)./2
			o.κs .= 1 ./ (1 .- (o.κs .- sqrtNaN.(o.κs.^2 .- o.x₁₁ .* o.x₂₂ .+ o.x₁₂ .* o.x₂₁)) ./ 
			                   (o.YY₁₁ .* o.YY₂₂ .- o.YY₁₂ .* o.YY₁₂))  # solve quadratic equation for smaller eignenvalue; last term is det(o.YY✻)
			!iszero(o.fuller) && (o.κs .-= o.fuller / (o._Nobs - o.kX))
			_As .= o.κs .* (o.YPXY₂₂ .- o.YY₂₂) .+ o.YY₂₂
			o.β̈s .= (o.κs .* (o.YPXY₁₂ .- o.YY₁₂) .+ o.YY₁₂) ./ _As
		else
			HessianFixedkappa!(o, _As, [1], 1, o.κ)
			HessianFixedkappa!(o, o.β̈s, [1], 0, o.κ); o.β̈s ./= _As
		end

		if o.null
			o.numerWRE .= o.β̈s .+ (o.Repl.Rt₁ - o.r) / o.Repl.RRpar
		else
			o.numerWRE .= o.β̈s .- view(o.DGP.β̈ ,:,1)
			isone(w) && (o.numerWRE[1] = o.β̈s[1] + (o.Repl.Rt₁[1] - o.r[1]) / o.Repl.RRpar[1])
		end

		@storeWtGrpResults!(o.numer, o.numerWRE)
		if o.bootstrapt
			if o.robust
				J⋂s1 = dropdims(o.J⋂s; dims=3)
				Filling!(o, J⋂s1, 1, o.β̈s)
				J⋂s1 ./= _As
				t✻!(reshape(o.denom[1,1],1,:,1), (o.clust[1].even ? o.clust[1].multiplier : -o.clust[1].multiplier), o.J⋂s', o.J⋂s)
				@inbounds for c ∈ 2:o.NErrClustCombs  # sum sandwich over error clusteringssrc/WRE.jl
					nrows(o.clust[c].order)>0 && 
						(J⋂s1 .= J⋂s1[o.clust[c].order,:])
					panelsum!(dropdims(o.Jc[c]; dims=3), J⋂s1, o.clust[c].info)
		    	coldotplus!(o.denom[1,1], (o.clust[c].even ? o.clust[c].multiplier : -o.clust[c].multiplier), dropdims(o.Jc[c]; dims=3))
				end
			else
				o.denom[1,1] .= (HessianFixedkappa(o, [0], 0, zero(T)) .-   # XXX rewrite to avoid allocations
				                     2 .* o.β̈s .* HessianFixedkappa(o, [0], 1, zero(T)) .+ 
								             o.β̈s.^2 .* HessianFixedkappa(o, [1], 1, zero(T))) ./ o._Nobs ./ _As  # classical error variance
			end
			@storeWtGrpResults!(o.dist, o.sqrt ? o.numerWRE ./ sqrtNaN.(o.denom[1,1]) : o.numerWRE .^ 2 ./ o.denom[1,1])
			o.denom[1,1] .*= o.Repl.RRpar[1]^2
		end
		w==1 && o.bootstrapt && (o.statDenom = [o.denom[1,1][1];;])  # original-sample denominator

  else  # WRE bootstrap for more than 1 retained coefficient in bootstrap regression

		if o.liml
			@inbounds for i ∈ 0:o.Repl.kZ
				HessianFixedkappa!(o, view(o.YY✻  , 1:i+1, :, i+1), collect(0:i), i, zero(T))  # κ=0 => Y*MZperp*Y
				HessianFixedkappa!(o, view(o.YPXY✻, 1:i+1, :, i+1), collect(0:i), i,  one(T))  # κ=1 => Y*PXpar*Y
			end
			symmetrize!(o.YY✻)
			symmetrize!(o.YPXY✻)

			@inbounds for b ∈ axes(o.κWRE,2)
				o.κWRE[b] = 1/(1 - real(eigvalsNaN(invsym(view(o.YY✻,:,b,:)') * Symmetric(view(o.YPXY✻,:,b,:)))[1]))
			end
			!iszero(o.fuller) && (o.κWRE .-= o.fuller / (o._Nobs - o.kX))

			o.As .= o.κWRE .* view(o.YPXY✻, 2:o.Repl.kZ+1, :, 2:o.Repl.kZ+1) .+ (1 .- o.κWRE) .* view(o.YY✻, 2:o.Repl.kZ+1, :, 2:o.Repl.kZ+1)
			invsym!(o.As)
			t✻!(view(o.β̈s,:,:,1:1), o.As, o.κWRE .* view(o.YPXY✻, 2:o.Repl.kZ+1, :, 1) .+ (1 .- o.κWRE) .* view(o.YY✻, 2:o.Repl.kZ+1, :,  1))
		else
			HessianFixedkappa!(o, o.δnumer, collect(1:o.Repl.kZ), 0, o.κ)
			@inbounds for i ∈ 1:o.Repl.kZ
				HessianFixedkappa!(o, view(o.As, 1:i, :, i), collect(1:i), i, o.κ)
			end
			symmetrize!(o.As)
			invsym!(o.As)
			t✻!(view(o.β̈s,:,:,1:1), o.As, view(o.δnumer,:,:,1:1))
		end

		if o.bootstrapt
			if o.robust
				@inbounds for i ∈ 1:o.Repl.kZ  # avoid list comprehension construction for compiler-perceived type stability
					Filling!(o, view(o.J⋂s,:,:,i), i, o.β̈s)
				end
			else
				@inbounds for i ∈ 0:o.Repl.kZ
					HessianFixedkappa!(o, view(o.YY✻, 1:i+1, :, i+1), collect(0:i), i, zero(T))
				end
				symmetrize!(o.YY✻)
			end
		end

		if o.null
			o.numerWRE .= o.Repl.Rt₁ - o.r                ; t✻plus!(o.numerWRE, o.Repl.RRpar, o.β̈s)
		else
			o.numerWRE .= o.Repl.RRpar * (-o.DGP.β̈[:,1:1]); t✻plus!(o.numerWRE, o.Repl.RRpar, o.β̈s); 
			w==1 && b==1 && (o.numerWRE[:,1:1] .= o.Repl.RRpar * o.β̈s[:,1:1] .+ o.Repl.Rt₁ .- o.r)
		end

		if o.bootstrapt
			if o.robust  # Compute denominator for this WRE test stat
				t✻!(o.ARpars, o.As, o.Repl.RRpar')
				t✻!(o.J⋂ARpars, o.J⋂s, o.ARpars)
				t✻!(o.denomWRE, (o.clust[1].even ? o.clust[1].multiplier : -o.clust[1].multiplier), o.J⋂ARpars', o.J⋂ARpars)
				for c ∈ 2:o.NErrClustCombs
					(!isone(o.NClustVar) && nrows(o.clust[c].order)>0) &&
						(o.J⋂ARpars = o.J⋂ARpars[o.clust[c].order,:,:])
					panelsum!(reshape(o.Jc[c], o.clust[c].N, :), reshape(o.J⋂ARpars, o.N⋂, :), o.clust[c].info)
					t✻plus!(o.denomWRE, (o.clust[c].even ? o.clust[c].multiplier : -o.clust[c].multiplier), o.Jc[c]', o.Jc[c])
				end
			else  # non-robust
				tmp = view([fill(T(-1), 1, o.ncolsv) ; o.β̈s], :, :, 1:1)
				o.denomWRE .= (o.Repl.RRpar * o.As * o.Repl.RRpar') .* (tmp'o.YY✻ * tmp ./ o._Nobs)  # 2nd half is sig2 of errors
			end
			if w==1
				o.statDenom = o.denomWRE[:,1,:]
				o.numer[:,1] = o.numerWRE[:,1]
			end
			if o.sqrt
				@storeWtGrpResults!(o.dist, o.numerWRE ./ sqrtNaN.(dropdims(o.denomWRE; dims=3)))
			else
				invsym!(o.denomWRE)
				_numer = view(o.numerWRE,:,:,1:1)
				@storeWtGrpResults!(o.dist, dropdims(_numer'o.denomWRE*_numer; dims=3))  # hand-code for 2-dimensional?  XXX allocations
			end
		else
			@storeWtGrpResults!(o.numer, o.numerWRE)
		end
	end
	nothing
end

using Plots


annotate!(x, y, z, text) = annotate!(Plots.current(), x, y, z, text)
annotate!(x::Number, y::Number, z::Number, text::AbstractString) = annotate!(Plots.current(), [x], [y], [z], [text])
annotate!(p, x::Number, y::Number, z::Number, text::AbstractString) = annotate!(p, [x], [y], [z], [text])
function annotate!(p, x, y, z, text)
    plot!(p, x, y, z, label=nothing)
    attr = p.series_list[end].plotattributes.explicit
    attr[:text] = text
    attr[:mode] = "text"
    return p
end


# Plots additions

plots_addons() = quote
    function Plots.plotly_series_segments(series::Plots.Series, plotattributes_base::Plots.KW, x, y, z, clims)
        st = series[:seriestype]
        sp = series[:subplot]
        isscatter = st in (:scatter, :scatter3d, :scattergl)
        hasmarker = isscatter || series[:markershape] !== :none
        istext = haskey(series.plotattributes, :mode) && series.plotattributes[:mode] == "text"
        hastext = haskey(series.plotattributes, :text)
    
        hasline = st in (:path, :path3d, :straightline)
        hasfillrange =
            st in (:path, :scatter, :scattergl, :straightline) &&
            (isa(series[:fillrange], AbstractVector) || isa(series[:fillrange], Tuple))
    
        segments = collect(Plots.series_segments(series, st))
        plotattributes_outs = fill(Plots.KW(), (hasfillrange ? 2 : 1) * length(segments))
    
        needs_scatter_fix = !isscatter && hasmarker && !any(isnan, y) && length(segments) > 1
    
        for (k, segment) in enumerate(segments)
            i, rng = segment.attr_index, segment.range
    
            plotattributes_out = deepcopy(plotattributes_base)
            plotattributes_out[:showlegend] = k == 1 ? Plots.should_add_to_legend(series) : false
            plotattributes_out[:legendgroup] = series[:label]
    
            # set the type
            if st in (:path, :scatter, :scattergl, :straightline)
                plotattributes_out[:type] = st === :scattergl ? "scattergl" : "scatter"
                plotattributes_out[:mode] = if istext
                    "text"
                elseif hasmarker
                    hasline ? "lines+markers" : "markers"
                else
                    hasline ? "lines" : "none"
                end
                if series[:fillrange] == true ||
                   series[:fillrange] == 0 ||
                   isa(series[:fillrange], Tuple)
                    plotattributes_out[:fill] = "tozeroy"
                    plotattributes_out[:fillcolor] = Plots.rgba_string(
                        Plots.plot_color(Plots.get_fillcolor(series, clims, i), Plots.get_fillalpha(series, i)),
                    )
                elseif typeof(series[:fillrange]) <: Union{AbstractVector{<:Real},Real}
                    plotattributes_out[:fill] = "tonexty"
                    plotattributes_out[:fillcolor] = Plots.rgba_string(
                        Plots.plot_color(get_fillcolor(series, clims, i), Plots.get_fillalpha(series, i)),
                    )
                elseif !(series[:fillrange] in (false, nothing))
                    @warn "fillrange ignored... plotly only supports filling to zero and to a vector of values. fillrange: $(series[:fillrange])"
                end
                plotattributes_out[:x], plotattributes_out[:y] = x[rng], y[rng]
    
            elseif st in (:path3d, :scatter3d)
                plotattributes_out[:type] = "scatter3d"
                plotattributes_out[:mode] = if istext
                    "text"
                elseif hasmarker
                    hasline ? "lines+markers" : "markers"
                else
                    hasline ? "lines" : "none"
                end
                plotattributes_out[:x], plotattributes_out[:y], plotattributes_out[:z] =
                    x[rng], y[rng], z[rng]
            end
            # add text
            if hastext
                plotattributes_out[:text] = series[:text]
            end
            # add "marker"
            if hasmarker
                mcolor = Plots.rgba_string(
                    Plots.plot_color(Plots.get_markercolor(series, clims, i), Plots.get_markeralpha(series, i)),
                )
                mcolor_next = if (mz = series[:marker_z]) !== nothing && i < length(mz)
                    Plots.plot_color(
                        Plots.get_markercolor(series, clims, i + 1),
                        Plots.get_markeralpha(series, i + 1),
                    ) |> rgba_string
                else
                    mcolor
                end
                lcolor = Plots.rgba_string(
                    Plots.plot_color(
                        Plots.get_markerstrokecolor(series, i),
                        Plots.get_markerstrokealpha(series, i),
                    ),
                )
                lcolor_next =
                Plots.plot_color(
                    Plots.get_markerstrokecolor(series, i + 1),
                    Plots.get_markerstrokealpha(series, i + 1),
                    ) |> rgba_string
    
                plotattributes_out[:marker] = Plots.KW(
                    :symbol => Plots.get_plotly_marker(
                        Plots._cycle(series[:markershape], i),
                        string(Plots._cycle(series[:markershape], i)),
                    ),
                    # :opacity => needs_scatter_fix ? [1, 0] : 1,
                    :size => 2Plots._cycle(series[:markersize], i),
                    :color => needs_scatter_fix ? [mcolor, mcolor_next] : mcolor,
                    :line => Plots.KW(
                        :color => needs_scatter_fix ? [lcolor, lcolor_next] : lcolor,
                        :width => Plots._cycle(series[:markerstrokewidth], i),
                    ),
                )
            end
    
            # add "line"
            if hasline
                plotattributes_out[:line] = Plots.KW(
                    :color => Plots.rgba_string(
                        Plots.plot_color(Plots.get_linecolor(series, clims, i), Plots.get_linealpha(series, i)),
                    ),
                    :width => Plots.get_linewidth(series, i),
                    :shape => if st === :steppre
                        "vh"
                    elseif st === :stepmid
                        "hvh"
                    elseif st === :steppost
                        "hv"
                    else
                        "linear"
                    end,
                    :dash => string(Plots.get_linestyle(series, i)),
                )
            end
    
            Plots.plotly_polar!(plotattributes_out, series)
            Plots.plotly_adjust_hover_label!(plotattributes_out, Plots._cycle(series[:hover], rng))
    
            if hasfillrange
                # if hasfillrange is true, return two dictionaries (one for original
                # series, one for series being filled to) instead of one
                plotattributes_out_fillrange = deepcopy(plotattributes_out)
                plotattributes_out_fillrange[:showlegend] = false
                # if fillrange is provided as real or tuple of real, expand to array
                if typeof(series[:fillrange]) <: Real
                    plotattributes_out[:fillrange] = fill(series[:fillrange], length(rng))
                elseif typeof(series[:fillrange]) <: Tuple
                    f1 =
                        (fr1 = series[:fillrange][1]) |> typeof <: Real ?
                        fill(fr1, length(rng)) : fr1[rng]
                    f2 =
                        (fr2 = series[:fillrange][2]) |> typeof <: Real ?
                        fill(fr2, length(rng)) : fr2[rng]
                    plotattributes_out[:fillrange] = (f1, f2)
                end
                if isa(series[:fillrange], AbstractVector)
                    plotattributes_out_fillrange[:y] = series[:fillrange][rng]
                    delete!(plotattributes_out_fillrange, :fill)
                    delete!(plotattributes_out_fillrange, :fillcolor)
                else
                    # if fillrange is a tuple with upper and lower limit, plotattributes_out_fillrange
                    # is the series that will do the filling
                    plotattributes_out_fillrange[:x], plotattributes_out_fillrange[:y] =
                        Plots.concatenate_fillrange(x[rng], series[:fillrange])
                    plotattributes_out_fillrange[:line][:width] = 0
                    delete!(plotattributes_out, :fill)
                    delete!(plotattributes_out, :fillcolor)
                end
    
                plotattributes_outs[(2k - 1):(2k)] =
                    [plotattributes_out_fillrange, plotattributes_out]
            else
                plotattributes_outs[k] = plotattributes_out
            end
            plotattributes_outs[k] = merge(plotattributes_outs[k], series[:extra_kwargs])
        end
    
        if series[:line_z] !== nothing
            push!(plotattributes_outs, Plots.plotly_colorbar_hack(series, plotattributes_base, :line))
        elseif series[:fill_z] !== nothing
            push!(plotattributes_outs, Plots.plotly_colorbar_hack(series, plotattributes_base, :fill))
        elseif series[:marker_z] !== nothing
            push!(
                plotattributes_outs,
                Plots.plotly_colorbar_hack(series, plotattributes_base, :marker),
            )
        end
    
        plotattributes_outs
    end
    
    function Plots.plotly_layout(plt::Plots.Plot)
        plotattributes_out = Plots.KW()
    
        w, h = plt[:size]
        plotattributes_out[:width], plotattributes_out[:height] = w, h
        plotattributes_out[:paper_bgcolor] = Plots.rgba_string(plt[:background_color_outside])
        plotattributes_out[:margin] = Plots.KW(:l => 0, :b => 20, :r => 0, :t => 20)
    
        plotattributes_out[:annotations] = KW[]
    
        multiple_subplots = length(plt.subplots) > 1
    
        for sp in plt.subplots
            spidx = multiple_subplots ? sp[:subplot_index] : ""
            x_idx, y_idx = multiple_subplots ? Plots.plotly_link_indicies(plt, sp) : ("", "")
            
            equal_aspect = Plots.get_aspect_ratio(sp) === :equal #∈ [:equal, :none]
            
            # add an annotation for the title
            if sp[:title] != ""
                bb = Plots.plotarea(sp)
                tpos = sp[:titlelocation]
                if tpos === :left
                    xmm, ymm = Plots.left(bb), Plots.top(Plots.bbox(sp))
                    halign, valign = :left, :top
                elseif tpos === :center
                    xmm, ymm = 0.5(Plots.left(bb) + Plots.right(bb)), Plots.top(Plots.bbox(sp))
                    halign, valign = :hcenter, :top
                elseif tpos === :right
                    xmm, ymm = Plots.right(bb), Plots.top(Plots.bbox(sp))
                    halign, valign = :right, :top
                else
                    xmm = Plots.left(bb) + tpos[1] * Plots.width(bb)
                    # inverting to make consistent with GR
                    ymm = Plots.bottom(bb) - tpos[2] * Plots.height(bb)
                    halign, valign = sp[:titlefonthalign], sp[:titlefontvalign]
                end
                titlex, titley = Plots.xy_mm_to_pcts(xmm, ymm, w * Plots.px, h * Plots.px)
                title_font = Plots.font(Plots.titlefont(sp), halign = halign, valign = valign)
                push!(
                    plotattributes_out[:annotations],
                    Plots.plotly_annotation_dict(titlex, titley, Plots.text(sp[:title], title_font)),
                )
            end
    
            plotattributes_out[:plot_bgcolor] = Plots.rgba_string(sp[:background_color_inside])
    
            # set to supported framestyle
            sp[:framestyle] = Plots._plotly_framestyle(sp[:framestyle])
    
            if Plots.ispolar(sp)
                plotattributes_out[Symbol("angularaxis$(spidx)")] =
                Plots.plotly_polaraxis(sp, sp[:xaxis])
                plotattributes_out[Symbol("radialaxis$(spidx)")] =
                Plots.plotly_polaraxis(sp, sp[:yaxis])
            else
                x_domain, y_domain = Plots.plotly_domain(sp)
                if Plots.RecipesPipeline.is3d(sp)
                    azim = sp[:camera][1] - 90 #convert azimuthal to match GR behaviour
                    theta = 90 - sp[:camera][2] #spherical coordinate angle from z axis
                    plotattributes_out[Symbol(:scene, spidx)] = Plots.KW(
                        :domain => Plots.KW(:x => x_domain, :y => y_domain),
                        Symbol("xaxis$(spidx)") => Plots.plotly_axis(sp[:xaxis], sp),
                        Symbol("yaxis$(spidx)") => Plots.plotly_axis(sp[:yaxis], sp),
                        Symbol("zaxis$(spidx)") => Plots.plotly_axis(sp[:zaxis], sp),
                        :aspectmode=> equal_aspect ? "data" : "data",
                        #2.6 multiplier set camera eye such that whole plot can be seen
                        :camera => Plots.KW(
                            :eye => Plots.KW(
                                :x => 2.6cosd(azim) * sind(theta),
                                :y => 2.6sind(azim) * sind(theta),
                                :z => 2.6cosd(theta),
                            ),
                            :projection => (
                                auto = "orthographic",  # we choose to unify backends by using a default "orthographic" proj when `:auto`
                                ortho = "orthographic",
                                orthographic = "orthographic",
                                persp = "perspective",
                                perspective = "perspective",
                            )[sp[:projection_type]],
                        ),
                    )
                else
                    plotattributes_out[Symbol("xaxis$(x_idx)")] =
                    Plots.plotly_axis(sp[:xaxis], sp, string("y", y_idx), x_domain)
                    # don't allow yaxis to be reupdated/reanchored in a linked subplot
                    if spidx == y_idx
                        plotattributes_out[Symbol("yaxis$(y_idx)")] =
                        Plots.plotly_axis(sp[:yaxis], sp, string("x", x_idx), y_domain)
                    end
                end
            end
            
            # legend
            Plots.plotly_add_legend!(plotattributes_out, sp)
    
            # annotations
            for ann in sp[:annotations]
                append!(
                    plotattributes_out[:annotations],
                    KW[Plots.plotly_annotation_dict(
                        Plots.locate_annotation(sp, ann...)...;
                        xref = "x$(x_idx)",
                        yref = "y$(y_idx)",
                    )],
                )
            end
            # series_annotations
            for series in Plots.series_list(sp)
                anns = series[:series_annotations]
                for (xi, yi, str, fnt) in Plots.EachAnn(anns, series[:x], series[:y])
                    push!(
                        plotattributes_out[:annotations],
                        Plots.plotly_annotation_dict(
                            xi,
                            yi,
                            Plots.PlotText(str, fnt);
                            xref = "x$(x_idx)",
                            yref = "y$(y_idx)",
                        ),
                    )
                end
            end
            
            Plots.ispolar(sp) && (plotattributes_out[:direction] = "counterclockwise")
            plotattributes_out
        end
    
        # turn off hover if nothing's using it
        if all(series -> series.plotattributes[:hover] in (false, :none), plt.series_list)
            plotattributes_out[:hovermode] = "none"
        end
        
        plotattributes_out = Plots.recursive_merge(plotattributes_out, plt.attr[:extra_plot_kwargs])
        
        plotattributes_out
    end

function Plots.axis_limits(
    sp,
    letter,
    lims_factor = Plots.widen_factor(Plots.get_axis(sp, letter)),
    consider_aspect = true,
)
    axis = Plots.get_axis(sp, letter)
    ex = axis[:extrema]
    amin, amax = ex.emin, ex.emax
    lims = Plots.process_limits(axis[:lims], axis)
    lims === nothing && Plots.warn_invalid_limits(axis[:lims], letter)

    if (has_user_lims = lims isa Tuple)
        lmin, lmax = lims
        if lmin isa Number && Plots.isfinite(lmin)
            amin = lmin
        elseif lmin isa Symbol
            lmin === :auto || @warn "Invalid min $(letter)limit" lmin
        end
        if lmax isa Number && isfinite(lmax)
            amax = lmax
        elseif lmax isa Symbol
            lmax === :auto || @warn "Invalid max $(letter)limit" lmax
        end
    end
    if lims === :symmetric
        amax = max(abs(amin), abs(amax))
        amin = -amax
    end
    if amax ≤ amin && isfinite(amin)
        amax = amin + 1.0
    end
    if !isfinite(amin) && !isfinite(amax)
        amin, amax = zero(amin), one(amax)
    end
    if Plots.ispolar(axis.sps[1])
        if axis[:letter] === :x
            amin, amax = 0, 2π
        elseif lims === :auto
            # widen max radius so ticks dont overlap with theta axis
            amin, amax = 0, amax + 0.1abs(amax - amin)
        end
    elseif lims_factor !== nothing
        amin, amax = Plots.scale_lims(amin, amax, lims_factor, axis[:scale])
    elseif lims === :round
        amin, amax = Plots.round_limits(amin, amax, axis[:scale])
    end
    aspect_ratio = Plots.get_aspect_ratio(sp)
    if (
        !has_user_lims &&
        consider_aspect &&
        letter in (:x, :y) &&
        !(aspect_ratio === :none || Plots.RecipesPipeline.is3d(sp))
    )
        println("Not equal")
        aspect_ratio = aspect_ratio isa Number ? aspect_ratio : 1
        area = Plots.plotarea(sp)
        plot_ratio = Plots.height(area) / Plots.width(area)
        dist = amax - amin

        factor = if letter === :x
            ydist, = Plots.axis_limits(sp, :y, Plots.widen_factor(sp[:yaxis]), false) |> collect |> diff
            axis_ratio = aspect_ratio * ydist / dist
            axis_ratio / plot_ratio
        else
            xdist, = Plots.axis_limits(sp, :x, Plots.widen_factor(sp[:xaxis]), false) |> collect |> diff
            axis_ratio = aspect_ratio * dist / xdist
            plot_ratio / axis_ratio
        end

        if factor > 1
            center = (amin + amax) / 2
            amin = center + factor * (amin - center)
            amax = center + factor * (amax - center)
        end
    end

    amin, amax
end


end |> eval

begin 
    backend = Plots.backend()
    try
        plotlyjs()
        plots_addons() 
    catch _
    end
    try
        plotly()
        plots_addons() 
    catch _
    end
    Plots.backend(backend)
end
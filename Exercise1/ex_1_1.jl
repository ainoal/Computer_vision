# Read and show image

# Packages that I added for plotting and images
#Pkg.activate(@__DIR__)
#Pkg.add("Plots")
#Pkg.add("PlotlyJS")
#Pkg.add("Plotly")
#Pkg.add("PlotlyBase")
#Pkg.add("PlotlyKaleido")
#Pkg.add("Images")

using Pkg
using Plots
using Images
lena = load("lenastd.png")
plot(lena)

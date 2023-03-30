using Images
using Pkg
Pkg.instantiate()

function main()
    # Load the sequence of images and stack them to a 3D matrix with dimensions
    # height x width x time
    img_seq = readdir(joinpath(@__DIR__, "../data/seq1"))
    img_matrix = load(joinpath(@__DIR__, "../data/seq1/", img_seq[1]))
    for i in 2:10
        new_img = load(joinpath(@__DIR__, "../data/seq1/", img_seq[i]))
        img_matrix = cat(img_matrix, new_img; dims=3)
    end

end

main()

# Script to build the MultiDocumenter demo docs
#
#   julia --project docs/make.jl [--temp] [deploy]
#
# When `deploy` is passed as an argument, it goes into deployment mode
# and attempts to push the generated site to gh-pages. You can also pass
# `--temp`, in which case the source repositories are cloned into a temporary
# directory (as opposed to `docs/clones`).

using MultiDocumenter
using Documenter

DEPLOY_TOKEN = get(ENV, "DEPLOY_TOKEN", "")
REPO_NAME = get(ENV, "REPO_NAME", "")

clonedir = ("--temp" in ARGS) ? mktempdir() : joinpath(@__DIR__, "clones")
outpath = mktempdir()
@info """
Cloning packages into: $(clonedir)
Building aggregate site into: $(outpath)
"""

@info "Building aggregate MultiDocumenter site"
docs = [
    # We also add MultiDocumenter's own generated pages
    # MultiDocumenter.MultiDocRef(
    #     upstream = joinpath(@__DIR__, "build"),
    #     path = "docs",
    #     name = "PiccoloMultidocs",
    #     fix_canonical_url = false,
    # ),
    MultiDocumenter.MultiDocRef(
        upstream = joinpath(clonedir, "Piccolo"),
        path = "Piccolo",
        name = "Piccolo",
        giturl = "https://github.com/harmoniqs/Piccolo.jl.git",
    ),
    MultiDocumenter.MultiDocRef(
        upstream = joinpath(clonedir, "PiccoloQuantumObjects"),
        path = "PiccoloQuantumObjects",
        name = "Quantum Objects",
        giturl = "https://github.com/harmoniqs/PiccoloQuantumObjects.jl.git",
    ),
    MultiDocumenter.DropdownNav(
        "Optimal Controls",
        [
            MultiDocumenter.MultiDocRef(
                upstream = joinpath(clonedir, "QuantumCollocation"),
                path = "QuantumCollocation",
                name = "QuantumCollocation.jl",
                giturl = "https://github.com/harmoniqs/QuantumCollocation.jl.git",
            ),
            MultiDocumenter.MultiDocRef(
                upstream = joinpath(clonedir, "DirectTrajOpt"),
                path = "DirectTrajOpt",
                name = "DirectTrajOpt.jl",
                giturl = "https://github.com/harmoniqs/DirectTrajOpt.jl.git",
            ),
        ],
    ),
    MultiDocumenter.DropdownNav(
        "Trajectories",
        [
            MultiDocumenter.MultiDocRef(
                upstream = joinpath(clonedir, "NamedTrajectories"),
                path = "NamedTrajectories",
                name = "NamedTrajectories.jl",
                giturl = "https://github.com/harmoniqs/NamedTrajectories.jl.git",
            ),
            MultiDocumenter.MultiDocRef(
                upstream = joinpath(clonedir, "TrajectoryIndexingUtils"),
                path = "TrajectoryIndexingUtils",
                name = "TrajectoryIndexingUtils.jl",
                giturl = "https://github.com/harmoniqs/TrajectoryIndexingUtils.jl.git",
            ),
        ],
    ),
    MultiDocumenter.MultiDocRef(
        upstream = joinpath(clonedir, "PiccoloPlots"),
        path = "PiccoloPlots",
        name = "Plots",
        giturl = "https://github.com/harmoniqs/PiccoloPlots.jl.git",
    ),

    MultiDocumenter.DropdownNav(
        "Archive",
        [
            MultiDocumenter.MultiDocRef(
                upstream = joinpath(clonedir, "QuantumCollocationCore"),
                path = "QuantumCollocationCore",
                name = "QuantumCollocationCore.jl",
                giturl = "https://github.com/harmoniqs/QuantumCollocationCore.jl.git",
            ),
        ]
    ),
]

MultiDocumenter.make(
    outpath,
    docs;
    search_engine = MultiDocumenter.SearchConfig(
        index_versions = ["dev"],
        engine = MultiDocumenter.FlexSearch,
    ),
    rootpath = "/",
    canonical_domain = "https://docs.harmoniqs.co/",
    sitemap = true,
)

cp(normpath(joinpath(@__DIR__, "..", "CNAME")), joinpath(outpath, "CNAME"), force=true)

# Always copy the built docs to the output directory
@info "Built documentation in: $(outpath)"
cp(outpath, joinpath(@__DIR__, "out"), force = true)
function data()
  return {
    info {
     name = "TF2LiveMap Exporer",
     description = "Export Lines and Station for an external map.",
     minorVersion = 0,
     severityAdd = "NONE",
     severityRemove = "NONE",
     tags = {"Export", "Web", "TF2LiveMap", "Script"},
     authors = {
       {
         name = "TheBlokker",
         role = "Developer",
       },
     },
   },
   runFn = function(settings)
     require "exporter"
   end
  }
end

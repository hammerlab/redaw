
let () =
  Redaw.Dataset.(
    let dummy = paired_end ~r1:[] ~r2:[] in
    static ~host:Local ~name:"World"
      (Dna { normal = dummy; tumors = []})
      None
      |> name
  ) |> Printf.printf "Hello %s\n%!"

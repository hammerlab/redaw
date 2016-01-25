
let () =
  Redaw.Dataset.(
    create ~name:"World" (pointer_to "Dummy")
    |> name
  ) |> Printf.printf "Hello %s\n%!"

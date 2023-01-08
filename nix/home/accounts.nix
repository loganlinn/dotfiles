{...}: {
  accounts.email.accounts.fastmail = {
    address = "logan@loganlinn.com";
    aliases = ["admin@loganlinn.com" "webmaster@loganlinn.com" "logan@llinn.dev"];
    userName = "logan@loganlinn.com"; # https://www.fastmail.help/hc/en-us/articles/1500000278342
    realName = "Logan Linn";
    primary = true;
    flavor = "fastmail.com";
    # passwordCommand = "op item get 3s436l7qdbgjzcnwehyj5fze6i --fields label=password";
  };
}

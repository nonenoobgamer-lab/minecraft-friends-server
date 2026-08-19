# Economy plugins — DO NOT INSTALL

The following are explicitly excluded from this server:

- Vault
- ChestShop / QuickShop / ShopGUIPlus
- AuctionHouse / CrazyAuctions
- PlayerPoints
- Crate / key plugins
- Donation store bridges

## EssentialsX economy disabled

See `config/plugins/Essentials/config.yml`:

- `starting-balance: 0`
- Disabled: pay, bal, sell, worth, eco
- Home commands disabled (DonutHomes handles /home)

## Verify after deploy

In server console:

```
/plugins
```

Confirm no shop or economy plugins appear.

Test that these fail for players:

- `/pay`
- `/bal`
- `/sell`

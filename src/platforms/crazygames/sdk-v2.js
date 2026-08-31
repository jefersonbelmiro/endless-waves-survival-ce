(() => {
  let has_ad_block = null;
  let canvas;
  let top_banner_container;
  let left_banner_container;
  let right_banner_container;
  let display_banners = false;
  let gameplay_started = false;

  const side_banners_min_width = 1080;

  function gameplay_start() {
    if (gameplay_started) return;
    gameplay_started = true;
    window.CrazyGames.SDK.game.gameplayStart();
  }

  function gameplay_stop() {
    if (!gameplay_started) return;
    gameplay_started = false;
    window.CrazyGames.SDK.game.gameplayStop();
  }

  function get_user(done) {
    const callback = (error, isAvailable) => {
      if (error || !isAvailable) {
        done("user is not avaliable", null);
        return;
      }
      window.CrazyGames.SDK.user.getUser(done);
    };
    window.CrazyGames.SDK.user.isUserAccountAvailable(callback);
  }

  function request_rewarded(done) {
    return request_ad("rewarded", done);
  }

  function request_midgame(done) {
    return request_ad("midgame", done);
  }

  function request_ad(type, done) {
    const callbacks = {
      adFinished: () => {
        canvas?.focus();
        done(null);
      },
      adError: (_error) => {
        canvas?.focus();
        done(true);
      },
      adStarted: () => {
        canvas?.blur();
      },
    };
    window.CrazyGames.SDK.ad.requestAd(type, callbacks);
  }

  function init_banners() {
    top_banner_container = document.body.appendChild(
      element_set(document.createElement("div"), {
        id: "top-banner-container",
        style: {
          display: "none",
          position: "absolute",
          top: "0",
          left: "calc(50% - 160px)",
          width: "320px",
          height: "50px",
        },
      })
    );

    left_banner_container = document.body.appendChild(
      element_set(document.createElement("div"), {
        id: "left-banner-container",
        style: {
          display: "none",
          position: "absolute",
          top: "0",
          left: "0",
          width: "250px",
          height: "250px",
        },
      })
    );

    right_banner_container = document.body.appendChild(
      element_set(document.createElement("div"), {
        id: "right-banner-container",
        style: {
          display: "none",
          position: "absolute",
          top: "0",
          right: "0",
          width: "250px",
          height: "250px",
        },
      })
    );

    window.addEventListener("resize", () => {
      toggle_display_banners();
    });
  }

  function toggle_display_banners() {
    top_banner_container.style.display = !display_banners ? "none" : "block";
    left_banner_container.style.display =
      !display_banners || window.innerWidth < side_banners_min_width
        ? "none"
        : "block";
    right_banner_container.style.display =
      !display_banners || window.innerWidth < side_banners_min_width
        ? "none"
        : "block";
  }

  function request_banners() {
    if (!top_banner_container) init_banners();
    show_banners();
    window.CrazyGames.SDK.banner.requestResponsiveBanner(
      top_banner_container.id
    );
    if (window.innerWidth > side_banners_min_width) {
      window.CrazyGames.SDK.banner.requestResponsiveBanner(
        left_banner_container.id
      );
      window.CrazyGames.SDK.banner.requestResponsiveBanner(
        right_banner_container.id
      );
    }
  }

  function show_banners() {
    display_banners = true;
    toggle_display_banners();
  }

  function hide_banners() {
    display_banners = false;
    toggle_display_banners();
  }

  function element_set(element, properties_obj) {
    for (const prop in properties_obj) {
      const value = properties_obj[prop];
      if (typeof value === "object" && value !== null) {
        element_set(element[prop], value);
      } else {
        element[prop] = value;
      }
    }
    return element;
  }

  function init(done) {
    canvas = document.querySelector("#canvas");
    window.CrazyGames.SDK.getEnvironment((_error, environment) => {
      const disabled = !(environment !== "disabled");
      done(disabled);
    });

    // window.CrazyGames.SDK.ad.hasAdblock((error, result) => {
    //   if (error) return;
    //   has_ad_block = result;
    // });
  }

  window.SDK = {
    init,
    gameplay_start,
    gameplay_stop,
    has_ad_block,
    request_rewarded,
    request_midgame,
    request_banners,
    show_banners,
    hide_banners,
    get_user,
  };
})();

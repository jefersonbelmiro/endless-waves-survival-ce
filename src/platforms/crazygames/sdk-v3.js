(() => {
  let canvas;
  let gameplay_started = false;

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

  function request_rewarded(done) {
    return request_ad("rewarded", done);
  }

  function request_midgame(done) {
    return request_ad("midgame", done);
  }

  async function get_user(done) {
    console.log(
      "get_user",
      !window.CrazyGames.SDK.user?.isUserAccountAvailable
    );
    if (!window.CrazyGames.SDK.user?.isUserAccountAvailable) {
      done(null);
    }
    try {
      const result = await window.CrazyGames.SDK.user.getUser();
      done(result);
    } catch (e) {
      console.log("get_user error", e);
      done(result);
    }
  }

  function persist_data(key, data) {
    console.log("persist_data", key);
    try {
      window.CrazyGames.SDK.data.setItem(key, data);
      return true;
    } catch (err) {
      console.log("persist_data error", err);
      return false;
    }
  }

  function load_data(key) {
    console.log("load_data", key);
    try {
      return window.CrazyGames.SDK.data.getItem(key);
    } catch (err) {
      console.log("load_data error", err);
      return null;
    }
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

  async function init(done) {
    try {
      canvas = document.querySelector("#canvas");
      await window.CrazyGames.SDK.init();
      console.log("sdk init", window.CrazyGames.SDK);
      const environment = window.CrazyGames.SDK.environment;
      const disabled = !(environment !== "disabled");
      done(disabled);
    } catch (er) {
      done(true);
    }
  }

  console.log("sdk v3");

  window.SDK = {
    init,
    gameplay_start,
    gameplay_stop,
    request_rewarded,
    request_midgame,
    get_user,
    persist_data,
    load_data,
  };
})();

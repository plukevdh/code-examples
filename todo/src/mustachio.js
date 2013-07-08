(function() {
  var Mustachio;

  Mustachio = (function() {
    Mustachio.prototype.templates = {};

    function Mustachio(model) {
      this.model = model;
    }

    Mustachio.prototype.render = function() {
      return this.templates[this.templateName].call(this, this.renderContext());
    };

    Mustachio.prototype.lazyCompileFactory = function(template_id, raw_template) {
      var _this = this;
      return this.templates[template_id] = function(context) {
        var compiled_template;
        compiled_template = Handlebars.compile(raw_template);
        _this.templates[_this.id] = compiled_template;
        return compiled_template(context);
      };
    };

    Mustachio.prototype.renderContext = function() {
      if (this.model) {
        return this.model.toJSON();
      } else {
        return {};
      }
    };

    Mustachio.prepare = function() {
      var _this = this;
      return $('script[type="text/x-handlebars-template"]').each(function(i, item) {
        var raw_template;
        raw_template = item.textContent;
        if (!raw_template) {
          raw_template = item.innerHTML;
        }
        return _this.prototype.lazyCompileFactory(item.id, raw_template);
      });
    };

    return Mustachio;

  })();

  window.Mustachio = Mustachio;

  $(function() {
    return Mustachio.prepare();
  });

}).call(this);

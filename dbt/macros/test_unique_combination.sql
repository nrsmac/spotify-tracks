{% test unique_combination(model, combination) %}

select
    {% for col in combination %}
    {{ col }}{% if not loop.last %}, {% endif %}
    {% endfor %}
from {{ model }}
group by
    {% for col in combination %}
    {{ col }}{% if not loop.last %}, {% endif %}
    {% endfor %}
having count(*) > 1

{% endtest %}

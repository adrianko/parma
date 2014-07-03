from api.models import *
from django.db.models import Max
import components
from json import loads
def get(response, id):
    try:
        c = Category.objects.get(pk=id)
        response.setOk()
        response.data.append(c.fetch())
    except Category.DoesNotExist:
        pass
    return response

def getTasks(response, id):
    if get(response, id).code == 200:
        response.data = [t.fetch() for t in Task.objects.filter(category_id=id)]
    return response

def create(data):
    if data == {}:
        response = {"success": False, "request": data}
    else:
        max_order = Category.objects.filter(
            board=Board.objects.get(pk=data.get("id"))
        ).aggregate(Max('order'))['order__max']

        if max_order is None:
            max_order = 0
        
        c = Category(
            title=data.get("title"),
            description="",
            board=Board.objects.get(pk=data.get("id")),
            order=int(max_order)+1
        )
        c.save()

        response = {"success": True, "request": data, "id": c.fetch()["id"]}

        if data["component"] == "1":
            response["components"] = components.category()
    return response

def setOrder(data):
    if data == {}:
        response = {"success": False, "request": data}
    else:
        order = loads(data.get("order"))
        for x in range(0, len(order)):
            try:
                c = Category.objects.get(pk=int(order[x]))
                c.order = (x+1)
                c.save(update_fields=["order"])
            except Category.DoesNotExist:
                pass
        response = {"success": True, "request": data}
    return response
from sqlalchemy import String
from sqlalchemy.orm import Mapped, mapped_column, relationship

from app.infra.database import Base


class Client(Base):
    __tablename__ = "clients"

    id: Mapped[int] = mapped_column(primary_key=True, autoincrement=True)
    full_name: Mapped[str] = mapped_column(String(150), nullable=False)
    phone: Mapped[str] = mapped_column(String(20), nullable=False)
    license_plate: Mapped[str] = mapped_column(String(10), nullable=False, index=True)
    vehicle_brand_model: Mapped[str | None] = mapped_column(String(100), nullable=True)

    appointments: Mapped[list["Appointment"]] = relationship(
        back_populates="client"
    )

    def __repr__(self) -> str:
        return f"<Client id={self.id} name={self.full_name!r} plate={self.license_plate!r}>"